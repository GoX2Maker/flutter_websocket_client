import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  WebSocketChannel? channel;
  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();
  final String serverUrl = 'ws://localhost:4040/ws';
  final Duration reconnectInterval = const Duration(seconds: 5); // 재연결 시도 간격

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    } catch (e) {
      print('Error: $e');
      _reconnect();
    }

    channel!.stream.listen(
      (message) {
        setState(() {
          messages.add(message.toString());
        });

        if (message == 'ping') {
          channel!.sink.add('pong');
          print('Received ping, sent pong');
        }
      },
      onDone: () {
        print('Connection is closed');
        _reconnect();
      },
      onError: (error) {
        print('Error: $error');
        _reconnect();
      },
    );
  }

  void _reconnect() {
    print(
        'Attempting to reconnect in ${reconnectInterval.inSeconds} seconds...');
    Future.delayed(reconnectInterval, () {
      if (mounted) {
        setState(() {
          _connectWebSocket();
        });
      }
    });
  }

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebSocket Chat'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: messages
                      .map((msg) => ListTile(
                            title: Text(msg),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration:
                            const InputDecoration(labelText: 'Send a message'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          channel?.sink.add(controller.text);
                          controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
