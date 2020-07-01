

import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'game_communication.dart';
import 'package:http/http.dart' as http;


//const URL ='http://192.168.0.143:34260/api/getPoints/';
const URL ='http://192.168.0.14:34260/api/getPoints/';

const USERNAME="EKESHI";
class ConnectivityWidget extends StatefulWidget {

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  var nrPoints=null;
  var tokeBuddy = "";
  var isToking = false;
 var  isQuestionShown =false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    print('init state called here');
    updatePointsAsync();
    gameCommunication.socket.on('LOBBY/READY_FOR_TOKE_GUEST',onHeConnected);

  }

  updatePointsAsync() async {

    if(mounted) {
      setState(() async {
        nrPoints = await updateUserPoints();
      });
    }
  }
  Future<int> updateUserPoints() async {
    print('Starting request');
    final response = await http.get(URL+USERNAME);
    print(response);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var points = jsonDecode(response.body)['points'];
      return points;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
  @override
  Widget build(BuildContext context) {
    return  !isToking ? Column(
      verticalDirection:VerticalDirection.down,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left:40.0,
              top:60.0),
              child: Text(
                USERNAME,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontFamily: "Schyler",
                    fontSize: 50,
                    color: Colors.white),
              ),
            ),
            Expanded(
              child:Container()
            ),

            Padding(
              padding: EdgeInsets.only(right: 40,top:50),
              child: Column(
                children: <Widget>[
                  Text(
                    "Ju keni mbledhur:",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 40,
                        color: Colors.white),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.nrPoints != null ? this.nrPoints.toString():"" ,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                            fontFamily: "Schyler",
                            fontSize: 50,
                            color: Colors.white),
                      ),
                      ImageIcon(
                        AssetImage("assets/toke.png"),
                        color: Colors.white,size: 70,)
                    ],
                  )
                ],
              ),
            ),

          ],

        ),
        NearbyPeopleWidget(()=>onConnectClicked(),(data)=>onTokeBuddyUpdate(data))

      ],
    ) : TokeWidget((newPoints)=>onBackClicked(newPoints),this.tokeBuddy,this.isQuestionShown);
  }

  onBackClicked(newPoints) {
    print('Executed Back');

    if (newPoints==null) {
      if (mounted) {
        setState(() {
          this.isToking = false;
        });
      }
    } else {
        if(mounted) {
          setState(() {
            this.isToking = false;
            nrPoints += newPoints;
          });
        }
    }
  }

  onConnectClicked() {
    if(mounted) {
      setState(() {
        this.isToking = true;
      });
    }
  }

  onTokeBuddyUpdate(data) {
    print(data);

    if(mounted){
      setState(() {
        this.tokeBuddy=data.toString();
      });
    }

  }

  onHeConnected(data) {
   setState(() {
      this.isToking=true;
      this.tokeBuddy=data;
   });
  }
}


class NearbyPeopleWidget extends StatefulWidget {

  Function isToking;
  Function updateTokeBuddyUsername;

  NearbyPeopleWidget(this.isToking,this.updateTokeBuddyUsername);

  @override
  _NearbyPeopleWidgetState createState() => _NearbyPeopleWidgetState();
}

class _NearbyPeopleWidgetState extends State<NearbyPeopleWidget> {

   List<String> entries = <String>[];

  bool isLocationPermissionGranted = false;
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocationData();

    Timer.periodic(new Duration(seconds: 1), (timer) {
      //print('Executing');
automaticLocationScanning();    });



    }

   void checkLocationData() async{
     GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
print("geolocation is "+geolocationStatus.toString());

     if(geolocationStatus != GeolocationStatus.granted){
     isLocationPermissionGranted =false;
     print("Came at false");
   } else {
     isLocationPermissionGranted=true;
     print("Came at true");

     if(isLocationPermissionGranted==true){
       print("inside");
       Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   //   print("Latitude"+position.latitude.toString());


       var obj = {'position': position,'username':USERNAME};

       var jsonText = jsonEncode(obj);

       gameCommunication.socket.emit("LOBBY/GET_NEARBY_USERS",jsonText);
       gameCommunication.socket.on("LOBBY/GET_NEARBY_USERS_ANSWER",handleNearbyUsersReceived);

     } else
       print("loccation not granted");

   }
   }


  @override
  Widget build(BuildContext context) {
    return isLocationPermissionGranted ? Padding(
      padding: const EdgeInsets.only(
          left: 40.0, right:40.0,
            top:40.0),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
            color: const Color(0xDA8E2D).withOpacity(0.5),

            borderRadius: BorderRadius.all(Radius.circular(100))
        ),
        child:  Padding(
          padding: const EdgeInsets.only(top:23.0,bottom: 23.0),
          child: Scrollbar(

            child: ListView.builder(

                padding: const EdgeInsets.only(right:40,
                left: 20,top:20,bottom: 20),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(

                      children:
                        [ Text(
                          entries[index],
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              fontFamily: "Schyler",
                              fontSize: 40,
                              color: Colors.white),
                        ),

                          Expanded(child: Container()),
                          RaisedButton(
                              onPressed:  () => onConnectPressed(index),
                              textColor: Colors.white,
                              color: Color(0xff003049),
                               shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),

                  ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                    "Lidhu",
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        fontFamily: "Schyler",
                                        fontSize: 40,
                                        color: Colors.white),
                                  ),
                              ),
                          )
                        ]
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    ) : GrantPermissionWidget();
  }

  requestNearbyUsers({position: Position,username: String}) {
      print("OK,connected");


  }

  handleNearbyUsersReceived(data){
    List users = jsonDecode(data);
    List<String> entries =[];
    for(var usr in users){
      print(usr['username']);
      entries.add(usr['username']);
    }
    if(mounted) {
      setState(() {
        this.entries = entries;
      });
    }
    //print(data);

  }

  callback(data) {
      //print("callback executed");
  }

  void onConnectPressed(entryIndex) {
      var otherUsername = entries[entryIndex];
      widget.updateTokeBuddyUsername(otherUsername);
      print("HELLO FROM NEW FUNCTION");
      gameCommunication.socket.emit("LOBBY/CONNECT_USER",otherUsername);
      gameCommunication.socket.on("LOBBY/READY_FOR_TOKE",onReadyForToke);

  }

  onReadyForToke(data) {

      print("Open Toke Dialog");
      widget.isToking();
  }



   automaticLocationScanning() async {
     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //print("Latitude"+position.latitude.toString());


     var obj = {'position': position,'username':USERNAME};

     var jsonText = jsonEncode(obj);
    gameCommunication.socket.emit("LOBBY/GET_NEARBY_USERS",jsonText);
  }
}


class GrantPermissionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,

        children: <Widget>[
          Container(
            width: 350,
            child: Text(
              "Per te perdorur sherbimin, ju lutem lejoni aksesimin e vendndodhjes.",
        textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  fontFamily: "Schyler",
                  fontSize: 30,
                  color: Colors.white),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: RaisedButton(
              onPressed: onActivateLocation,
              textColor: Colors.white,
              color: Color(0xff003049),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),

              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "AKTIVIZO",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontFamily: "Schyler",
                      fontSize: 50,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],


      ),
    );
  }

  void onActivateLocation() async {
    print("Here");
    PermissionStatus permission = await LocationPermissions().requestPermissions();
    print(permission.toString());
    PermissionStatus permission2 = await LocationPermissions().checkPermissionStatus();
    print(permission2);


    bool isShown = await LocationPermissions().shouldShowRequestPermissionRationale();
  print(isShown);
  }
}


class TokeWidget extends StatefulWidget {
  Function onBackClick;
  String otherUsername;
  bool isQuestionShown;

  TokeWidget(this.onBackClick,this.otherUsername,this.isQuestionShown);

  @override
  _TokeWidgetState createState() => _TokeWidgetState();
}

class _TokeWidgetState extends State<TokeWidget> {
  var isQuestionShown = false;
  var _animation = null;
  final FlareControls _controls = FlareControls();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gameCommunication.socket.on('TOKE/FINISH',onTokeFinsh);
    gameCommunication.socket.on('QUESTION/VALIDATE_ANSWER',onAnswerValidated);
  }

  onAnswerValidated(data){
    var obj = jsonDecode(data);

    var success = obj['success'];
    var newPoints=20;

    print(success);
    if(success==true){


      widget.onBackClick(newPoints);
    } else {
        widget.onBackClick(null);
    }

  }

  onTokeFinsh(data) {
    print('Toke Finished');
    print("TODO: Animation");

    if(mounted)
    setState(() {
     // this.isQuestionShown=true;
      _animation = "Untitled";


    });

    Future.delayed(const Duration(milliseconds: 5000), () {

// Here you can write your code

    if(data==true) {
      if (mounted)
        setState(() {
          this.isQuestionShown = true;
        });
    }
    });
    print("ask question");
  }

  validateAnswer(option){
    print('Validating');
    var isCorrect=false;
    if(option=="Hija e maleve"){
      isCorrect=true;
    }

    gameCommunication.socket.emit("QUESTION/ANSWER",option);

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:30.0,bottom:30,left:18,right:18),
      child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFF003049),

              borderRadius: BorderRadius.only(topRight: Radius.circular(100),topLeft: Radius.circular(100),bottomLeft: Radius.circular(100),bottomRight: Radius.circular(100))
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:32.0,top:40),
                child: GestureDetector(
                  onTap: ()=>widget.onBackClick(null),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 40.0,
                    semanticLabel:
                    'Text to announce in accessibility modes',
                  ),
                )),
                  Padding(
                    padding: const EdgeInsets.only(left:13.0,top:45),
                    child: Text(
                      "PRAPA",
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          fontFamily: "Schyler",
                          fontSize: 40,
                          color: Colors.white),

              ),
                  ),
            ],
          ),
      !isQuestionShown ?
          Column(
            children:[
              Container(
                  height:250,
                  width: 250,
                  child:_animation!=null ? new FlareActor("assets/Youth app animation.flr", alignment:Alignment.center, fit:BoxFit.cover,      animation: _animation,callback: (string) => {

                  },
                  ) : Container())
              /*ImageIcon(
            AssetImage("assets/toke.png"),
            color: Colors.white,size: 200),*/
              ,RaisedButton(
                onPressed:  () =>onTokePressed(),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0),

                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:20.0,right:30,left:30),
                  child: Text(
                    "TOKE",
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 100,
                        color: Color(0xff003049)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:35.0),
                child: Text(
                  "ME "+widget.otherUsername,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontFamily: "Schyler",
                      fontSize: 50,
                      color: Colors.white),
                ),
              ),
            ],
          ) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:40.0),
            child: Container(
              width: 300,
              child: new Text('Ismail Kadare, NUK ka shkruar librin :',style: TextStyle(
                  fontFamily: "sadasd",
                  fontSize: 30,
                  color: Colors.white),maxLines: 5, textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:50.0,left:50, right:50, bottom:10),
            child: Container(
               height: 270,

              decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.all(Radius.circular(30))
            ), child: Column(
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(top:20),
                  child: Container(),
                ),
                new ListTile(
                  onTap: ()=>
                    validateAnswer('Prilli i thyer'),
                  leading: new MyBullet(),
                  title: new Text('Prilli i thyer',style: TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xff003049)
                  ),),
                ),
                new ListTile(
                  onTap: ()=>
                      validateAnswer('Kohe Barbare'),
                  leading: new MyBullet(),
                  title: new Text('Kohe Barbare',style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xff003049)
                  )),
                )  ,
                new ListTile(
                  leading: new MyBullet(),
                  onTap: ()=>
                      validateAnswer('Hija e maleve'),
                  title: new Text('Hija e maleve',style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xff003049)
                  )),
                )       ,
                new ListTile(
                  leading: new MyBullet(),
                  onTap: ()=>
                      validateAnswer('Gjenerali i ushtrise se vdekur'),
                  title: new Text('Gjenerali i ushtrise se vdekur',style: TextStyle(
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xff003049)
                  )),
                )   ],
            ),
            ),
          ),
           Container(
             width:350,
             height: 60,
             child: Text('KUJDES! Nese pergjigjeni sakte, dyfishoni piket tuaja, ne te kundert'
                 'i humbisni ato. Gjithashtu mund te zgjidhni te mos pergjigjeni dhe te merrni'
                 'piket tuaja',style: TextStyle(
                fontFamily: "sadasd",
                fontSize: 14,
                color: Colors.white),maxLines: 5, textAlign: TextAlign.center,
          ),
           )
        ]
      )






        ],
      ),),
    );
  }

  onTokePressed() {

    gameCommunication.socket.emit("TOKE/ACK",widget.otherUsername);

   // gameCommunication.socket.on("LOBBY/TOKE_SUCCESS", )
  }



}


class MyBullet extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 10.0,
      width: 10.0,
      decoration: new BoxDecoration(
        color: const Color(0xff003049),
        shape: BoxShape.circle,
      ),
    );
  }
}

