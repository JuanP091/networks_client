import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessagePage extends StatefulWidget {
  final IO.Socket socket;

  const MessagePage({Key? key, required this.socket}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    setupSocketListeners();
  }

  void setupSocketListeners() {
    // Listen for connection limit event
    widget.socket.on("connection_limit", (data) {
      print(data); // Logs "Server only allows 2 users."
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Connection Limit"),
            content: Text(data),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Navigate back
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });

    widget.socket.on("receive_message", (data) {
      String sender = data['sender'] == widget.socket.id ? "You" : "Other User";
      String message = data['message'];

      setState(() {
        messages.add("$sender: $message");
      });
    });

    widget.socket.onDisconnect((_) {
      print("Disconnected from server");
    });
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      // Emit the message to the server
      widget.socket.emit("send_message", message);
      messageController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith("You:")
                          ? Colors.greenAccent.shade200
                          : Colors.blueAccent.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Enter a message",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    sendMessage(messageController.text); // Send the message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.socket.dispose(); // Clean up socket resources
    super.dispose();
  }
}
