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
  // WebSocket 서버에 연결합니다.
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:4040/ws'),
  );

  // 수신한 메시지를 저장할 리스트
  List<String> messages = [];

  // 텍스트 필드 컨트롤러
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
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
                child: StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      messages.add(snapshot.data.toString());
                    }
                    return ListView(
                      children: messages
                          .map((msg) => ListTile(
                                title: Text(msg),
                              ))
                          .toList(),
                    );
                  },
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
                          channel.sink.add(controller.text);
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
