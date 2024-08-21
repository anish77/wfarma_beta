import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

void main() {
  runApp(WfarmaBetaApp());
}

class WfarmaBetaApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'socket demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Instantiating the class with the Ip and the PortNumber
  TcpSocketConnection socketConnection =
      TcpSocketConnection("app.farmaconsult.it", 1045);

  String message = "";
  bool lLogin = false;

  @override
  void initState() {
    super.initState();
  }

  String extractJSON(String input) {
    return message = message.substring(message.indexOf(":") + 2);
  }

  //receiving and sending back a custom message
  void messageReceived(String msg) {
    setState(() {
      message = msg;
    });

    if (message.contains("dns")) {
      message = extractJSON(message);

      final oPayload = jsonDecode(message) as List;

      final oDns = oPayload.where((element) => element.contains("dns"));

      String cDns = oDns.last[1];
      socketConnection.disconnect();

      socketConnection = TcpSocketConnection("app.farmaconsult.it", 1045);

      connectAndSendMessage(
          "",
          "login: [\'a\',\'aa\',\'Farmaconsult 1.9.7.0\',\'unknown\',\'EDA52\',\'Android 11\', \'218.01.16.0219\', \'null\']",
          socketConnection);
    } else if (message.contains("login")) {}

    //socketConnection.disconnect();
  }

  //starting the connection and listening to the socket asynchronously
  void connectAndSendMessage(
      String cHostname, String msg, TcpSocketConnection tcpSocket) async {
    tcpSocket.enableConsolePrint(
        true); //use this to see in the console what's happening
    if (await tcpSocket.canConnect(5000, attempts: 3)) {
      //check if it's possible to connect to the endpoint
      await tcpSocket.connect(5000, messageReceived, attempts: 3);
      tcpSocket.sendMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
          child: Column(
            children: [
              Text("output >> $message"),
              ElevatedButton(
                onPressed: () {
                  connectAndSendMessage(
                      "app.farmaconsult.it",
                      'dns: [\'0116699410\',\'iOS 17.5.1\',\'Farmacia 2.1.1.1\']',
                      socketConnection); // Respond to button press
                },
                child: const Text('dns'),
              ),
              ElevatedButton(
                onPressed: () {
                  connectAndSendMessage(
                      "", "", socketConnection); // Respond to button press
                },
                child: const Text('login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
