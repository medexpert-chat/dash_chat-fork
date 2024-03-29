import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class QuickRepliesSample extends StatefulWidget {
  @override
  _QuickRepliesSampleState createState() => _QuickRepliesSampleState();
}

class _QuickRepliesSampleState extends State<QuickRepliesSample> {
  List<ChatMessage> messages = quickReplies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickReplies example'),
      ),
      body: DashChat(
        onRefresh: (context) => {},

        currentUser: user,
        onSend: (ChatMessage m) async  {
          setState(() {
            messages.insert(0, m);
          });
        },
        quickReplyOptions: QuickReplyOptions(onTapQuickReply: (QuickReply r) {
          final ChatMessage m = ChatMessage(
            user: user,
            text: r.value ?? r.title,
            createdAt: DateTime.now(),
          );
          setState(() {
            messages.insert(0, m);
          });
        }),
        messages: messages,
      ),
    );
  }
}
