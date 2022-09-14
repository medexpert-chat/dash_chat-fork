part of dash_chat_2;

// TODO: manage onMention

/// @nodoc
class InputToolbar extends StatefulWidget {
  const InputToolbar({
    required this.currentUser,
    required this.onSend,
    this.canSend = false,
    this.inputOptions = const InputOptions(),
    Key? key,
  }) : super(key: key);

  final bool canSend;

  /// Options to custom the toolbar
  final InputOptions inputOptions;

  /// Function to call when the message is sent (click on the send button)
  final Future<void> Function(ChatMessage) onSend;

  /// Current user using the chat
  final ChatUser currentUser;

  @override
  _InputToolbarState createState() => _InputToolbarState();
}

class _InputToolbarState extends State<InputToolbar> {
  late TextEditingController textController;
  final ValueNotifier<bool> sendingNotifier = ValueNotifier(false);

  @override
  void initState() {
    textController =
        widget.inputOptions.textController ?? TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    sendingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: widget.inputOptions.inputToolbarPadding,
        margin: widget.inputOptions.inputToolbarMargin,
        decoration: widget.inputOptions.inputToolbarStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (widget.inputOptions.leading != null)
              ...widget.inputOptions.leading!,
            Expanded(
              child: Directionality(
                textDirection: widget.inputOptions.inputTextDirection,
                child: TextField(
                  textAlignVertical: TextAlignVertical.top,
                  focusNode: widget.inputOptions.focusNode,
                  controller: textController,
                  enabled: !widget.inputOptions.inputDisabled,
                  textCapitalization: widget.inputOptions.textCapitalization,
                  textInputAction: widget.inputOptions.textInputAction,
                  decoration: widget.inputOptions.inputDecoration ??
                      defaultInputDecoration(),
                  maxLength: widget.inputOptions.maxInputLength,
                  minLines: widget.inputOptions.inputMinLines,
                  maxLines: widget.inputOptions.inputMaxLines,
                  cursorColor: widget.inputOptions.cursorStyle.color,
                  cursorWidth: widget.inputOptions.cursorStyle.width,
                  showCursor: !widget.inputOptions.cursorStyle.hide,
                  style: widget.inputOptions.inputTextStyle,
                  onSubmitted: (String value) {
                    if (widget.inputOptions.sendOnEnter) {
                      _sendMessage();
                    }
                  },
                  onChanged: (String value) {
                    setState(() {});
                    if (widget.inputOptions.onTextChange != null) {
                      widget.inputOptions.onTextChange!(value);
                    }
                  },
                ),
              ),
            ),
            if (widget.inputOptions.trailing != null &&
                widget.inputOptions.showTraillingBeforeSend &&
                !widget.inputOptions.alwaysShowSend &&
                textController.text.isEmpty)
              ...widget.inputOptions.trailing!,
            ValueListenableBuilder<bool>(
              valueListenable: sendingNotifier,
              builder: (context, value, _) {
                if (widget.inputOptions.alwaysShowSend ||
                    textController.text.isNotEmpty) {
                  return AbsorbPointer(
                    absorbing: value,
                    child: Opacity(
                      opacity: value ? 0.5 : 1,
                      child: widget.inputOptions.sendButtonBuilder != null
                          ? widget.inputOptions.sendButtonBuilder!(_sendMessage)
                          : defaultSendButton(
                          color: Theme.of(context).primaryColor)(
                        _sendMessage,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            if (widget.inputOptions.trailing != null &&
                !widget.inputOptions.showTraillingBeforeSend)
              ...widget.inputOptions.trailing!,
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (textController.text.trim().isNotEmpty || widget.canSend) {
      final ChatMessage message = ChatMessage(
        text: textController.text,
        user: widget.currentUser,
        createdAt: DateTime.now(),
      );
      sendingNotifier.value = true;
      await widget.onSend(message);
      sendingNotifier.value = false;
      if (widget.inputOptions.onTextChange != null) {
        widget.inputOptions.onTextChange!('');
      }
    }
  }
}
