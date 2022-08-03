import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class Basic extends StatefulWidget {
  @override
  _BasicState createState() => _BasicState();
}

const maxInputLength = 500;

class _BasicState extends State<Basic> {
  List<ChatMessage> messages = basicSample;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic example'),
      ),
      body: DashChat(
        messageOptions: MessageOptions(
          showOtherUsersAvatar: false,
          showOtherUsersName: false,
        ),
        onRefresh: (context) => {},
        inputOptions: InputOptions(
          inputToolbarMargin: const EdgeInsets.all(0),
          inputToolbarPadding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          onTextChange: (message) => {
            setState(() {}),
          },
          textController: _textController,
          cursorStyle: CursorStyle(color: Colors.green),
          showTraillingBeforeSend: true,
          trailing: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${_textController.text.length}/$maxInputLength',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
          sendButtonBuilder: (callback) => Padding(
            padding: const EdgeInsets.only(left: 3, top: 20, right: 3, bottom: 16),
            child: GestureDetector(
              child: Icon(Icons.send),
              onTap: () => callback(),
            ),
          ),
          leading: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: GestureDetector(
                child: Icon(Icons.attachment),
                onTap: () => {},
              ),
            ),
          ],
          inputToolbarStyle: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black12),
            ),
            color: Colors.white,
          ),
          alwaysShowSend: true,
          inputMinLines: 1,
          inputMaxLines: 4,
          maxInputLength: maxInputLength,
          inputDecoration: const InputDecoration(
            hintText: 'Текст обращения',
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
        currentUser: user,
        onSend: (ChatMessage m) {
          setState(() {
            messages.insert(0, m);
          });
        },
        messages: messages,
      ),
    );
  }
}
