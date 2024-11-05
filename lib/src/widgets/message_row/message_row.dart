part of dash_chat_2;

/// @nodoc
class MessageRow extends StatefulWidget {
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
    this.isGroupChat = false,
    Key? key,
  })  : color = color ?? Colors.transparent,
        super(key: key);

  final Color color;

  final Widget? resendIcon;

  final Future<void> Function(ChatMessage)? onResend;

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

  final bool isGroupChat;

  @override
  State<MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  final ValueNotifier<bool> sendingNotifier = ValueNotifier(false);

  @override
  void dispose() {
    sendingNotifier.dispose();
    super.dispose();
  }

  /// Get the avatar widget
  Widget getAvatar() {
    return widget.messageOptions.avatarBuilder != null
        ? widget.messageOptions.avatarBuilder!(
            widget.message.user,
            widget.messageOptions.onPressAvatar,
            widget.messageOptions.onLongPressAvatar,
          )
        : DefaultAvatar(
            user: widget.message.user,
            onLongPressAvatar: widget.messageOptions.onLongPressAvatar,
            onPressAvatar: widget.messageOptions.onPressAvatar,
          );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnMessage = widget.message.user.id == widget.currentUser.id;
    bool isPreviousSameAuthor = false;
    bool isNextSameAuthor = false;
    if (widget.previousMessage != null && widget.previousMessage!.user.id == widget.message.user.id) {
      isPreviousSameAuthor = true;
    }
    if (widget.nextMessage != null && widget.nextMessage!.user.id == widget.message.user.id) {
      isNextSameAuthor = true;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: widget.color,
      child: Row(
        crossAxisAlignment: widget.isGroupChat ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (widget.message.status == MessageStatus.pending &&
              widget.onResend != null &&
              widget.resendIcon != null)
            ValueListenableBuilder<bool>(
              valueListenable: sendingNotifier,
              builder: (context, sending, _) {
                return AbsorbPointer(
                  absorbing: sending,
                  child: Opacity(
                    opacity: sending ? 0.5 : 1,
                    child: InkWell(
                      onTap: () async {
                        sendingNotifier.value = true;
                        await widget.onResend!(widget.message);
                        sendingNotifier.value = false;
                      },
                      child: widget.resendIcon!,
                    ),
                  ),
                );
              },
            ),
          if (!widget.messageOptions.showOtherUsersAvatar) const Padding(padding: EdgeInsets.only(left: 10)),
          if (widget.isGroupChat && !isOwnMessage)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
              child: (widget.message.groupChatUser?.avatarUrl ?? '').isNotEmpty
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.message.groupChatUser?.avatarUrl ?? ''),
                    )
                  : const Icon(
                      Icons.broken_image_outlined,
                      size: 18,
                    ),
            ),
          GestureDetector(
            onLongPress: widget.messageOptions.onLongPressMessage != null
                ? () => widget.messageOptions.onLongPressMessage!(widget.message)
                : null,
            onTap: widget.messageOptions.onPressMessage != null
                ? () => widget.messageOptions.onPressMessage!(widget.message)
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (widget.messageOptions.top != null)
                    widget.messageOptions.top!(widget.message, widget.previousMessage, widget.nextMessage),
                  if (!isOwnMessage && widget.messageOptions.showOtherUsersName && !isPreviousSameAuthor)
                    widget.messageOptions.userNameBuilder != null
                        ? widget.messageOptions.userNameBuilder!(widget.message.user)
                        : DefaultUserName(user: widget.message.user),
                  VisibilityDetector(
                    key: Key(widget.message.id.toString()),
                    onVisibilityChanged: (info) => {
                      if (widget.messageOptions.onVisibilityChanges != null &&
                          !isOwnMessage &&
                          widget.message.status != MessageStatus.read)
                        {
                          widget.messageOptions.onVisibilityChanges!(widget.message),
                        }
                    },
                    child: Container(
                      decoration: widget.messageOptions.messageDecorationBuilder != null
                          ? widget.messageOptions.messageDecorationBuilder!(
                              widget.message, widget.previousMessage, widget.nextMessage)
                          : defaultMessageDecoration(
                              color: isOwnMessage
                                  ? (widget.messageOptions.currentUserContainerColor ??
                                      Theme.of(context).primaryColor)
                                  : (widget.messageOptions.containerColor ?? Colors.grey[100])!,
                              borderTopLeft: 18.0,
                              borderTopRight: 18.0,
                              borderBottomLeft: 18.0,
                              borderBottomRight: 18.0,
                            ),
                      padding: widget.messageOptions.messagePadding ?? const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (widget.isGroupChat)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                widget.message.groupChatUser?.fullName ?? '',
                                style: widget.messageOptions.textStyleGroupUser,
                              ),
                            ),
                          if (widget.message.medias != null &&
                              widget.message.medias!.isNotEmpty &&
                              !widget.messageOptions.textBeforeMedia)
                            widget.messageOptions.messageMediaBuilder != null
                                ? widget.messageOptions.messageMediaBuilder!(
                                    widget.message, widget.previousMessage, widget.nextMessage)
                                : MediaContainer(
                                    message: widget.message,
                                    isOwnMessage: isOwnMessage,
                                    messageOptions: widget.messageOptions,
                                  ),
                          if (widget.message.text.isNotEmpty)
                            TextContainer(
                              messageOptions: widget.messageOptions,
                              message: widget.message,
                              previousMessage: widget.previousMessage,
                              nextMessage: widget.nextMessage,
                              isOwnMessage: isOwnMessage,
                              isNextSameAuthor: isNextSameAuthor,
                              isPreviousSameAuthor: isPreviousSameAuthor,
                              messageTextBuilder: widget.messageOptions.messageTextBuilder,
                            ),
                          if (widget.message.medias != null &&
                              widget.message.medias!.isNotEmpty &&
                              widget.messageOptions.textBeforeMedia)
                            widget.messageOptions.messageMediaBuilder != null
                                ? widget.messageOptions.messageMediaBuilder!(
                                    widget.message, widget.previousMessage, widget.nextMessage)
                                : MediaContainer(
                                    message: widget.message,
                                    isOwnMessage: isOwnMessage,
                                    messageOptions: widget.messageOptions,
                                  ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.messageOptions.bottom != null)
                    widget.messageOptions.bottom!(widget.message, widget.previousMessage, widget.nextMessage),
                ],
              ),
            ),
          ),
          if (widget.messageOptions.showCurrentUserAvatar)
            Opacity(
              opacity: isOwnMessage && !isNextSameAuthor ? 1 : 0,
              child: getAvatar(),
            ),
          if (!widget.messageOptions.showCurrentUserAvatar) const Padding(padding: EdgeInsets.only(left: 10))
        ],
      ),
    );
  }
}
