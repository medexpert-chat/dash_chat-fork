import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class TypingUsersSample extends StatefulWidget {
  @override
  _TypingUsersSampleState createState() => _TypingUsersSampleState();
}

class _TypingUsersSampleState extends State<TypingUsersSample> {
  List<ChatMessage> messages = basicSample;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing user example'),
      ),
      body: DashChat(
        onRefresh: (context) => {},

        currentUser: user,
        onSend: (ChatMessage m) async  {
          setState(() {
            messages.insert(0, m);
          });
        },
        typingUsers: <ChatUser>[user3],
        messages: messages,
      ),
    );
  }
}
