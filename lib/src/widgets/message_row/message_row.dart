part of dash_chat_2;

/// @nodoc
class MessageRow extends StatelessWidget {
  const MessageRow({
    required this.message,
    required this.currentUser,
    Color? color,
    this.onResend,
    this.resendIcon,
    this.previousMessage,
    this.nextMessage,
    this.messageOptions = const MessageOptions(),
    this.lastMessageBottomPadding = 5,
    Key? key,
  })  : color = color ?? Colors.transparent,
        super(key: key);

  final Color color;

  final Widget? resendIcon;

  final Function(ChatMessage)? onResend;

  /// Current message to show
  final ChatMessage message;

  /// Previous message in the list
  final ChatMessage? previousMessage;

  /// Next message in the list
  final ChatMessage? nextMessage;

  /// Current user of the chat
  final ChatUser currentUser;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  final double lastMessageBottomPadding;

  /// Get the avatar widget
  Widget getAvatar() {
    return messageOptions.avatarBuilder != null
        ? messageOptions.avatarBuilder!(
            message.user,
            messageOptions.onPressAvatar,
            messageOptions.onLongPressAvatar,
          )
        : DefaultAvatar(
            user: message.user,
            onLongPressAvatar: messageOptions.onLongPressAvatar,
            onPressAvatar: messageOptions.onPressAvatar,
          );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnMessage = message.user.id == currentUser.id;
    bool isPreviousSameAuthor = false;
    bool isNextSameAuthor = false;
    if (previousMessage != null &&
        previousMessage!.user.id == message.user.id) {
      isPreviousSameAuthor = true;
    }
    if (nextMessage != null && nextMessage!.user.id == message.user.id) {
      isNextSameAuthor = true;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (message.status == MessageStatus.pending &&
              onResend != null &&
              resendIcon != null)
            InkWell(
              onTap: () => onResend!(message),
              child: resendIcon!,
            ),
          if (!messageOptions.showOtherUsersAvatar)
            const Padding(padding: EdgeInsets.only(left: 10)),
          GestureDetector(
            onLongPress: messageOptions.onLongPressMessage != null
                ? () => messageOptions.onLongPressMessage!(message)
                : null,
            onTap: messageOptions.onPressMessage != null
                ? () => messageOptions.onPressMessage!(message)
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isOwnMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (messageOptions.top != null)
                    messageOptions.top!(message, previousMessage, nextMessage),
                  if (!isOwnMessage &&
                      messageOptions.showOtherUsersName &&
                      !isPreviousSameAuthor)
                    messageOptions.userNameBuilder != null
                        ? messageOptions.userNameBuilder!(message.user)
                        : DefaultUserName(user: message.user),
                  VisibilityDetector(
                    key: Key(message.id.toString()),
                    onVisibilityChanged: (info) => {
                      if (messageOptions.onVisibilityChanges != null &&
                          !isOwnMessage &&
                          message.status != MessageStatus.read)
                        {
                          messageOptions.onVisibilityChanges!(message),
                        }
                    },
                    child: Container(
                      decoration: messageOptions.messageDecorationBuilder !=
                              null
                          ? messageOptions.messageDecorationBuilder!(
                              message, previousMessage, nextMessage)
                          : defaultMessageDecoration(
                              color: isOwnMessage
                                  ? (messageOptions.currentUserContainerColor ??
                                      Theme.of(context).primaryColor)
                                  : (messageOptions.containerColor ??
                                      Colors.grey[100])!,
                              borderTopLeft: 18.0,
                              borderTopRight: 18.0,
                              borderBottomLeft: 18.0,
                              borderBottomRight: 18.0,
                            ),
                      padding: messageOptions.messagePadding ??
                          const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: isOwnMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (message.medias != null &&
                              message.medias!.isNotEmpty &&
                              !messageOptions.textBeforeMedia)
                            messageOptions.messageMediaBuilder != null
                                ? messageOptions.messageMediaBuilder!(
                                    message, previousMessage, nextMessage)
                                : MediaContainer(
                                    message: message,
                                    isOwnMessage: isOwnMessage,
                                    messageOptions: messageOptions,
                                  ),
                          if (message.text.isNotEmpty)
                            TextContainer(
                              messageOptions: messageOptions,
                              message: message,
                              previousMessage: previousMessage,
                              nextMessage: nextMessage,
                              isOwnMessage: isOwnMessage,
                              isNextSameAuthor: isNextSameAuthor,
                              isPreviousSameAuthor: isPreviousSameAuthor,
                              messageTextBuilder:
                                  messageOptions.messageTextBuilder,
                            ),
                          if (message.medias != null &&
                              message.medias!.isNotEmpty &&
                              messageOptions.textBeforeMedia)
                            messageOptions.messageMediaBuilder != null
                                ? messageOptions.messageMediaBuilder!(
                                    message, previousMessage, nextMessage)
                                : MediaContainer(
                                    message: message,
                                    isOwnMessage: isOwnMessage,
                                    messageOptions: messageOptions,
                                  ),
                        ],
                      ),
                    ),
                  ),
                  if (messageOptions.bottom != null)
                    messageOptions.bottom!(
                        message, previousMessage, nextMessage),
                ],
              ),
            ),
          ),
          if (messageOptions.showCurrentUserAvatar)
            Opacity(
              opacity: isOwnMessage && !isNextSameAuthor ? 1 : 0,
              child: getAvatar(),
            ),
          if (!messageOptions.showCurrentUserAvatar)
            const Padding(padding: EdgeInsets.only(left: 10))
        ],
      ),
    );
  }
}
