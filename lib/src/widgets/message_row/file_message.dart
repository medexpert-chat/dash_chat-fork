import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class FileMessage extends StatefulWidget {
  const FileMessage({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    this.previousMessage,
    this.nextMessage,
    this.isPreviousSameAuthor = false,
    this.isNextSameAuthor = false,
    required this.media,
  }) : super(key: key);

  /// Message that contains the media to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  /// Previous message in the list
  final ChatMessage? previousMessage;

  /// Next message in the list
  final ChatMessage? nextMessage;

  /// If the previous message is from the same author as the current one
  final bool isPreviousSameAuthor;

  /// If the next message is from the same author as the current one
  final bool isNextSameAuthor;

  final ChatMedia media;

  @override
  State<FileMessage> createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage> {
  late final ChatMedia media;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    media = widget.media;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openOrDownload,
      child: TextContainer(
        isOwnMessage: widget.isOwnMessage,
        messageOptions: widget.messageOptions,
        message: widget.message,
        messageTextBuilder:
            (ChatMessage m, ChatMessage? p, ChatMessage? n) {
          return Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: !media.isUploading || !downloading
                    ? Icon(
                  Icons.description,
                  size: 18,
                  color: widget.isOwnMessage
                      ? (widget.messageOptions.currentUserTextColor ??
                      Colors.white)
                      : (widget.messageOptions.textColor ??
                      Colors.black),
                )
                    : const CircularProgressIndicator(),
              ),
              Flexible(
                child: Text(
                  media.fileName.split('/').last,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: widget.isOwnMessage
                        ? (widget.messageOptions.currentUserTextColor ??
                        Colors.white)
                        : (widget.messageOptions.textColor ?? Colors.black),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void openOrDownload() {
    download
  }
}
