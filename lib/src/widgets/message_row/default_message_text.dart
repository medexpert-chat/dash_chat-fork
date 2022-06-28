part of dash_chat_2;

/// {@category Default widgets}
class DefaultMessageText extends StatelessWidget {
  const DefaultMessageText({
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    Key? key,
  }) : super(key: key);

  /// Message tha contains the text to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        ParsedText(
          parse: messageOptions.parsePatterns != null
              ? messageOptions.parsePatterns!
              : defaultPersePatterns,
          text: message.text,
          style: TextStyle(
            color: isOwnMessage
                ? (messageOptions.currentUserTextColor ?? Colors.white)
                : (messageOptions.textColor ?? Colors.black),
          ),
        ),
        const SizedBox(height: 3),
        if (!messageOptions.textBeforeMedia || message.medias == null || message.medias!.isEmpty)
          Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (messageOptions.showTime)
              messageOptions.messageTimeBuilder != null
                  ? messageOptions.messageTimeBuilder!(message, isOwnMessage)
                  : Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        (messageOptions.timeFormat ?? intl.DateFormat('HH:mm'))
                            .format(message.createdAt),
                        style: TextStyle(
                          color: isOwnMessage
                              ? (messageOptions.currentUserTextColor ??
                                  Colors.white70)
                              : (messageOptions.textColor ?? Colors.black54),
                          fontSize: 10,
                        ),
                      ),
                    ),
            if (isOwnMessage && messageOptions.showReadStatus)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _getIconByStatus(message),
              ),
          ],
        ),
      ],
    );
  }

  Widget? _getIconByStatus(ChatMessage message) {
    switch (message.status) {
      case (MessageStatus.read):
        return messageOptions.readStatusIcon;
      case (MessageStatus.received):
        return messageOptions.receivedStatusIcon;
      case (MessageStatus.pending):
        return messageOptions.pendingStatusIcon;
      default:
        return Container();
    }
  }
}
