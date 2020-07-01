var app = require("express")();
var server = require("http").Server(app);
var user = require("./user.js");
var io= require("socket.io")(server);
var GeoPoint = require('geopoint');
const { json } = require("express");
var dbHandler = require('./database2.js');
const flatted = require('flatted');
const { SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS } = require("constants");

const DISTANCE_CONSIDERED_NEAR = 1800; // in meters

let users= {};

let location = {
    longitude:19.801930245012046,
    latitude: 41.31326540373266
};
//users["test1"] = new user("kot","test1","enasufi",location);

let gameState=[];

var port = process.env.port || 34260;

server.listen(port, function () {
  console.log("Server is now running... on port " + port);
})
 
app.get('/api/getPoints/:username',function(req,res){
        const username= req.params.username;
        console.log("Received point request ffrom :"+username);

        dbHandler.getPoints(username).then(function(result){
            if(result){
                console.log("Got query results " + JSON.stringify(result));
                res.json(result);

            }
        }, function(err){
            console.log(err)
        }).catch(function(err){
            console.log(err);
        })

    })

io.on('connection', function (socket){
     
    console.log("Connected successfully");

    socket.emit("connect",true);

    let myUser =  new user(socket,socket.id,null,null);

    users[socket.id]=myUser;

    var size =    Object.keys(users).length;


    console.log("Gjithsej " + size+ " perdorues");

    //console.log(findUserByUsername('kot'));
 
    
    //let nearbyUsers = findNearbyUsers(users,myUser);

    socket.on("LOBBY/GET_NEARBY_USERS",function(data){
        
        console.log(data);

        let parsedData = JSON.parse(data);
        let username = parsedData.username;
        let position = parsedData.position;
      //  console.log(users);
        users[socket.id].username=username;
        users[socket.id].location=position;
        console.log('username'+ username)
        console.log('position'+ position)

        console.log(findUserByUsername('kot'));
      //  console.log(users[socket.id]); 
        let nearbyUsers = findNearbyUsers(users,myUser)


        console.log("Number of nearby users is"+nearbyUsers.length);

      //  console.log(findUserByUsername('kot'));
        let toSend=[]
        for(let i=0;i<nearbyUsers.length;i++){
            toSend.push(new user(null,null,nearbyUsers[i].username,null))
        }
       // console.log(findUserByUsername('kot'));

        socket.emit("LOBBY/GET_NEARBY_USERS_ANSWER",JSON.stringify(toSend));

    });
 

    socket.on("LOBBY/CONNECT_USER",function(usernameToConnect){

        console.log(usernameToConnect);

       let userToConnect = findUserByUsername(usernameToConnect);
            //   console.log(userToConnect);
        //console.log(users);
       if(userToConnect!=null){
    console.log("Found user to connect");
        let state = {
            user1: socket.id,
            user2: userToConnect.socketId,
            ackForToke: 0,
            ackForAnswer:0
        }

        gameState.push(state);


        socket.emit('LOBBY/READY_FOR_TOKE');

        let user = findUserBySocketId(socket.id);
       // console.log(userToConnect);
        userToConnect.socket.emit('LOBBY/READY_FOR_TOKE_GUEST',user.username)
    
    
    }
    })

    socket.on('TOKE/ACK',function(otherUsername){
        console.log('ack request');
        let otherUser=  findUserByUsername(otherUsername);
        let otherUserSocketId = otherUser.socketId;
        for(let i=0;i<gameState.length;i++){

            st = gameState[i];

            if((st.user1 == socket.id || st.user1==otherUserSocketId) 
            && (st.user2 == socket.id || st.user2==otherUserSocketId))
       {
           console.log('Found my GameState');
           gameState[i].ackForToke++;
           console.log('incremented');
        console.log('new val'+gameState[i].ackForToke);
        

           if(gameState[i].ackForToke==2){

            let creatorSocketId = gameState[i].user1;

            if(socket.id==creatorSocketId){
                console.log('DONE. Emiting')
                socket.emit('TOKE/FINISH',true);
                otherUser.socket.emit('TOKE/FINISH',false);
            } else if(otherUser.socket.id==creatorSocketId){
                socket.emit('TOKE/FINISH',false);
                otherUser.socket.emit('TOKE/FINISH',true);
            }
               
           }
       }
        }

    })
    
    socket.on('QUESTION/ANSWER',function(option){

        console.log(option);
       var isCorrect=false;
        if(option=='Hija e maleve'){
            isCorrect=true;
        } 

        if(isCorrect){
           //TODO: isnertINtoDB; 
        }

        let obj = {
            success: isCorrect
        }

        for(let i=0;i<gameState.length;i++){

            st = gameState[i];

            if(st.user1 == socket.id  
             )
       {
           console.log('Found my GameState');

            console.log('This user socket Id'+socket.id);

            console.log(st);
          var  otherPlayerSocketId = gameState[i].user2;

          console.log(otherPlayerSocketId)

           var otherUser = findUserBySocketId(otherPlayerSocketId);

           otherUser.socket.emit('QUESTION/VALIDATE_ANSWER',JSON.stringify(obj))
           console.log('incremented');
        console.log('new val'+gameState[i]);
       }}

        socket.emit('QUESTION/VALIDATE_ANSWER',JSON.stringify(obj));


    })

    socket.on('disconnect', function () {
        //clearInterval(interval);
        console.log("disconnected"); 
        //Remove player from PlayersList;
        delete users[socket.id]; 

        console.log("Nr i lojtareve te mbetur eshte " +  Object.keys(users).length);
      });


 /*    socket.on('connectionRequest',function(data){
        parsedData = json.parse(data);

        let buddyUsername = parsedData.buddyUsername;
        let myUsername = findUserBySocketId(socket.id).username;

        console.log("Attempt  from "+myUsername+" to connect to:"+buddyUsername);

    }) */
})


function findNearbyUsers(users,myUser){
     let nearbyUsers = [];


const myPoint = new GeoPoint(myUser.location.latitude, myUser.location.longitude);
console.log(myPoint);
for(key of Object.keys(users)){
console.log("key:"+key);


    let user = users[key];
    if((user.socketId != myUser.socketId)
    && user.username!=myUser.username){
 
     if(user.location==null)
     continue; 
       let  point2 = new GeoPoint(user.location.latitude, user.location.longitude);
        var distance = myPoint.distanceTo(point2, true)
        let distanceInMeters = distance*1000;
        console.log("Distance in meters is"+distanceInMeters);


        if(distanceInMeters<=DISTANCE_CONSIDERED_NEAR){
            nearbyUsers.push(user);
           
        }

        console.log(point2);
    }   
} 

    

    return nearbyUsers;
}
 

function findUserBySocketId(socketIdp){


    console.log(Object.keys(users));
    for(key of Object.keys(users)){
        let usr = users[key];
        //console.log(usr);
        if(usr != null && usr.socketId==socketIdp){
            return usr;
        }

    }

    console.log('NULL');

    return null;

}

function findUserByUsername(userName){
    for(key of Object.keys(users)){
        let usr = users[key];
        if(usr != null && usr.username==userName){
            return usr;
        }

    }

    return null;
}


