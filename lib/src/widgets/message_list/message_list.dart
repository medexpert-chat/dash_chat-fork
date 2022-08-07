part of dash_chat_2;

/// @nodoc
class MessageList extends StatefulWidget {
  const MessageList({
    required this.currentUser,
    required this.messages,
    required this.onRefresh,
    this.messageOptions = const MessageOptions(),
    this.messageListOptions = const MessageListOptions(),
    this.quickReplyOptions = const QuickReplyOptions(),
    this.scrollToBottomOptions = const ScrollToBottomOptions(),
    this.typingUsers,
    Key? key,
  }) : super(key: key);

  final Function onRefresh;

  /// The current user of the chat
  final ChatUser currentUser;

  /// List of messages visible in the chat
  final List<ChatMessage> messages;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  /// Options to customize the behaviour and design of the overall list of message
  final MessageListOptions messageListOptions;

  /// Options to customize the behaviour and design of the quick replies
  final QuickReplyOptions quickReplyOptions;

  /// Options to customize the behaviour and design of the scroll-to-bottom button
  final ScrollToBottomOptions scrollToBottomOptions;

  /// List of users currently typing in the chat
  final List<ChatUser>? typingUsers;

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool scrollToBottomIsVisible = false;
  bool topReached = false;
  late ScrollController scrollController;
  RefreshController refreshController = RefreshController();
  List<ChatMessage> highlitedMessages = [];

  @override
  void initState() {
    scrollController =
        widget.messageListOptions.scrollController ?? ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Stack(
        children: <Widget>[
          Container(
            color: widget.messageListOptions.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: SmartRefresher(
                      onRefresh: () => {
                        widget.onRefresh(context),
                        Future.delayed(const Duration(seconds: 1), () {
                          refreshController.refreshCompleted();
                        }),
                      },
                      controller: refreshController,
                      child: ListView.builder(
                        controller: scrollController,
                        reverse: true,
                        itemCount: widget.messages.length,
                        itemBuilder: (BuildContext context, int i) {
                          final ChatMessage? previousMessage =
                              i < widget.messages.length - 1
                                  ? widget.messages[i + 1]
                                  : null;
                          final ChatMessage? nextMessage =
                              i > 0 ? widget.messages[i - 1] : null;
                          final ChatMessage message = widget.messages[i];

                          return Column(
                            children: <Widget>[
                              if (_shouldShowDateSeparator(
                                  previousMessage, message))
                                widget.messageListOptions
                                            .dateSeparatorBuilder !=
                                        null
                                    ? widget.messageListOptions
                                            .dateSeparatorBuilder!(
                                        message.createdAt)
                                    : DefaultDateSeparator(
                                        date: message.createdAt,
                                        messageListOptions:
                                            widget.messageListOptions,
                                      ),
                              if (widget.messageOptions.messageRowBuilder !=
                                  null) ...<Widget>[
                                widget.messageOptions.messageRowBuilder!(
                                  message,
                                  previousMessage,
                                  nextMessage,
                                ),
                              ] else
                                MessageRow(
                                  resendIcon: widget.messageOptions.resendIcon,
                                  onResend: widget.messageOptions.onResend,
                                  color: widget.messages[i].id ==
                                          widget
                                              .messageOptions.highlitedMessageId
                                      ? Color.fromRGBO(21, 204, 171, 0.05)
                                      : Colors.transparent,
                                  message: widget.messages[i],
                                  nextMessage: nextMessage,
                                  previousMessage: previousMessage,
                                  currentUser: widget.currentUser,
                                  messageOptions: widget.messageOptions,
                                  lastMessageBottomPadding: widget
                                      .messageListOptions
                                      .lastMessageBottomPadding,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (widget.typingUsers != null &&
                    widget.typingUsers!.isNotEmpty)
                  ...widget.typingUsers!.map((ChatUser user) {
                    if (widget.messageListOptions.typingBuilder != null) {
                      return widget.messageListOptions.typingBuilder!(user);
                    }
                    return DefaultTypingBuilder(user: user);
                  }).toList(),
                if (widget.messageListOptions.showFooterBeforeQuickReplies &&
                    widget.messageListOptions.chatFooterBuilder != null)
                  widget.messageListOptions.chatFooterBuilder!,
                if (widget.messages.isNotEmpty &&
                    widget.messages.first.quickReplies != null &&
                    widget.messages.first.quickReplies!.isNotEmpty &&
                    widget.messages.first.user.id != widget.currentUser.id)
                  QuickReplies(
                    quickReplies: widget.messages.first.quickReplies!,
                    quickReplyOptions: widget.quickReplyOptions,
                  ),
                if (!widget.messageListOptions.showFooterBeforeQuickReplies &&
                    widget.messageListOptions.chatFooterBuilder != null)
                  widget.messageListOptions.chatFooterBuilder!,
              ],
            ),
          ),
          if (topReached &&
              widget.messageListOptions.loadEarlierBuilder != null)
            Positioned(
              top: 8.0,
              child: widget.messageListOptions.loadEarlierBuilder!,
            ),
          if (!widget.scrollToBottomOptions.disabled && scrollToBottomIsVisible)
            widget.scrollToBottomOptions.scrollToBottomBuilder != null
                ? widget.scrollToBottomOptions
                    .scrollToBottomBuilder!(scrollController)
                : DefaultScrollToBottom(
                    scrollController: scrollController,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    textColor: Theme.of(context).primaryColor,
                  ),
        ],
      ),
    );
  }

  /// Check if a date separator needs to be shown
  bool _shouldShowDateSeparator(
      ChatMessage? previousMessage, ChatMessage message) {
    if (!widget.messageListOptions.showDateSeparator) {
      return false;
    }
    if (previousMessage == null) {
      // Means this is the first message
      return true;
    }
    switch (widget.messageListOptions.separatorFrequency) {
      case SeparatorFrequency.days:
        final DateTime previousDate = DateTime(
          previousMessage.createdAt.year,
          previousMessage.createdAt.month,
          previousMessage.createdAt.day,
        );
        final DateTime messageDate = DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        );
        return previousDate.difference(messageDate).inDays.abs() > 0;
      case SeparatorFrequency.hours:
        final DateTime previousDate = DateTime(
          previousMessage.createdAt.year,
          previousMessage.createdAt.month,
          previousMessage.createdAt.day,
          previousMessage.createdAt.hour,
        );
        final DateTime messageDate = DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
          message.createdAt.hour,
        );
        return previousDate.difference(messageDate).inHours.abs() > 0;
      default:
        return false;
    }
  }

  /// Sroll listener to trigger different actions:
  /// show scroll-to-bottom btn and LoadEarlier behaviour
  bool _onScroll(ScrollNotification scrollNotification) {
    setState(() {
      topReached = scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange;
    });
    if (topReached && widget.messageListOptions.onLoadEarlier != null) {
      widget.messageListOptions.onLoadEarlier!();
    }
    if (scrollNotification.metrics.pixels == 0) {
      if (scrollToBottomIsVisible) {
        setState(() {
          scrollToBottomIsVisible = false;
        });
      }
    } else if (scrollNotification.metrics.pixels > 200) {
      if (!scrollToBottomIsVisible) {
        setState(() {
          scrollToBottomIsVisible = true;
        });
      }
    }
    return true;
  }
}
