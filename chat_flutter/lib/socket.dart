import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
class ConnectSocket{
    connectToServer() async {
    IO.Socket  socket= io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    //connect to web socket
    socket.connect();
  }
}