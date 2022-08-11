part of dash_chat_2;

/// @nodoc
class MediaContainer extends StatelessWidget {
  const MediaContainer({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    this.previousMessage,
    this.nextMessage,
    this.isPreviousSameAuthor = false,
    this.isNextSameAuthor = false,
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

  /// Get the right media widget according to its type
  Widget _getMedia(ChatMedia media) {
    final Widget loading = Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.all(10),
      child: const CircularProgressIndicator(),
    );
    switch (media.type) {
      case MediaType.audio:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            AudioMessage(
              key: ValueKey(media.url),
              url: media.url,
            ),
            if (media.isUploading) loading
          ],
        );
      case MediaType.video:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            VideoPlayer(url: media.url),
            if (media.isUploading) loading
          ],
        );
      case MediaType.image:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            GestureDetector(
              onTap: messageOptions.onTapMedia != null
                  ? () => messageOptions.onTapMedia!(media)
                  : null,
              child: Image(
                fit: BoxFit.fill,
                alignment:
                    isOwnMessage ? Alignment.topRight : Alignment.topLeft,
                image: _getImage(media.url),
              ),
            ),
            if (media.isUploading) loading
          ],
        );
      default:
        return TextContainer(
          isOwnMessage: isOwnMessage,
          messageOptions: messageOptions,
          message: message,
          messageTextBuilder: (ChatMessage m, ChatMessage? p, ChatMessage? n) {
            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: !media.isUploading
                      ? Icon(
                          Icons.description,
                          size: 18,
                          color: isOwnMessage
                              ? (messageOptions.currentUserTextColor ??
                                  Colors.white)
                              : (messageOptions.textColor ?? Colors.black),
                        )
                      : loading,
                ),
                Flexible(
                  child: Text(
                    media.fileName,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: isOwnMessage
                          ? (messageOptions.currentUserTextColor ??
                              Colors.white)
                          : (messageOptions.textColor ?? Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  /// Get the right image provider if the image is local or remote
  ImageProvider _getImage(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return FileImage(
        File(url),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.medias != null && message.medias!.isNotEmpty) {
      final List<ChatMedia> media = message.medias!;
      return Column(
        crossAxisAlignment:
            (isOwnMessage) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: isOwnMessage ? WrapAlignment.end : WrapAlignment.start,
            children: media.map(
              (ChatMedia m) {
                return Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(top: 5, right: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        m.isUploading ? Colors.white54 : Colors.transparent,
                        BlendMode.srcATop,
                      ),
                      child: _getMedia(m),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          if (message.text.isEmpty || messageOptions.textBeforeMedia)
            Column(
              children: [
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (messageOptions.showTime)
                      messageOptions.messageTimeBuilder != null
                          ? messageOptions.messageTimeBuilder!(
                              message, isOwnMessage)
                          : Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                (messageOptions.timeFormat ??
                                        intl.DateFormat('HH:mm'))
                                    .format(message.createdAt),
                                style: TextStyle(
                                  color: isOwnMessage
                                      ? (messageOptions.currentUserTextColor ??
                                          Colors.white70)
                                      : (messageOptions.textColor ??
                                          Colors.black54),
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
            ),
        ],
      );
    }
    return Container();
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
