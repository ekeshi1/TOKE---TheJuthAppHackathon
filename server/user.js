
    function User(socket, socketId,username, location) {
        this.username = username;
        this.socket = socket;
        this.location = location;

        this.socketId= socketId;

    }


  module.exports.setUsername = function(username){
       this.username=username;
   }

   
  module.exports.setLocation = function(location){
    this.location=location;
}


module.exports = User;