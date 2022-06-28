import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../data.dart';

class Media extends StatefulWidget {
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  List<ChatMessage> messages = media;
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media example'),
      ),
      body: DashChat(
        onRefresh: (context) => refresh(context),
        currentUser: user,
        onSend: (ChatMessage m) {
          setState(() {
            messages.insert(0, m);
          });
        },
        messages: basicSample + messages + headerMessage,
        messageOptions: const MessageOptions(
          textBeforeMedia: true,
          showOtherUsersAvatar: false,
          readStatusIcon: Icon(
            Icons.mark_email_read,
            size: 14,
          ),
          pendingStatusIcon: Icon(Icons.pending_outlined),
          receivedStatusIcon: Icon(Icons.call_received),
        ),
        inputOptions: InputOptions(
          inputToolbarPadding: EdgeInsets.zero,
          onTextChange: (message) => {
            setState(() {}),
          },
          textController: textController,
          sendButtonBuilder: (callback) => Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                '${textController.text.length}/40',
                style: const TextStyle(color: Colors.grey),
              ),
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.link),
                ),
                onTap: () => callback(),
              ),
            ],
          ),
          inputToolbarStyle: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black12),
            ),
          ),
          alwaysShowSend: true,
          leading: [
            const Icon(Icons.link),
          ],
          maxInputLength: 500,
          inputMinLines: 1,
          inputDecoration: const InputDecoration(
            fillColor: Colors.green,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 10),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 0.1,
                style: BorderStyle.none,
              ),
            ),
          ),
          sendOnEnter: true,
        ),
        messageListOptions: MessageListOptions(
          dateSeparatorFormat: intl.DateFormat('dd MMMM', 'ru'),
        ),
      ),
    );
  }

  void refresh(BuildContext context) {
    debugPrint('d');
  }
}
