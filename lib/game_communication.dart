import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:socket_io_client/socket_io_client.dart' as IO;
GameCommunication gameCommunication= new GameCommunication();
class GameCommunication {

  static final GameCommunication _gameCommunication= new GameCommunication._internal() ;
  IO.Socket socket ;
  factory GameCommunication(){
    return _gameCommunication;
  }

  GameCommunication._internal(){
    //socket = IO.io('http://10.188.142.16:34260',<String, dynamic>{'transports': ['websocket']});
    print("Triying to connect");
   // socket = IO.io('http://192.168.0.143:34260', <String, dynamic>{'transports': ['websocket']});
    //
     socket = IO.io('http://192.168.0.14:34260',<String, dynamic>{'transports': ['websocket']});
    //  socket = IO.io('http://172.20.10.4:34260', <String, dynamic>{'transports': ['websocket']});
    socket.on("connect",_handleConnect);
  }

  _handleConnect(data) {
    print("Connected");
  }
}



