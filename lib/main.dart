import 'package:flutter/material.dart';
import 'package:flutter_application_2/message_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp()); // Entry point of the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  bool buttonPressed = false;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  void connect() {
    socket = IO.io("https://empty-pug-86.telebit.io/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    // Connect to the server
    socket.connect();

    // Log connection success
    socket.onConnect((_) {
      print("Connected to the server");
    });

    // Listen for 'receive_message' event
    socket.on("receive_message", (data) {
      print("Message received: ${data['message']} from ${data['sender']}");
      setState(() {
        messages.add("From ${data['sender']}: ${data['message']}");
      });
    });

    // Handle connection errors
    socket.onConnectError((data) {
      print("Connection Error: $data");
    });

    // Handle general errors
    socket.onError((data) {
      print("Error: $data");
    });

    // Handle disconnection
    socket.onDisconnect((_) {
      print("Disconnected from server");
    });

    print("Connecting to the server...");
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      socket.emit("send_message", message); // Send the message to the server
      setState(() {
        messages.add("You: $message"); // Add the message to the list
      });
      messageController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Direct Messages!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  buttonPressed = true; // Ensure the status message updates
                });
                connect();
                socket.onConnect((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessagePage(socket: socket)),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Connect to Server'),
            ),
            const SizedBox(height: 30),
            Text(
              buttonPressed
                  ? "Connecting to server..."
                  : "Click to Connect to server",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
