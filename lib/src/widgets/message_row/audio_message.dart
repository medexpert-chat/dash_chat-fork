part of dash_chat_2;

const Color primary = Color(0xff15CCAB);
const Color gray = Color(0xA6000000);
const Color background = Color(0xD9F4F4F4);

const double width = 250;

class AudioMessage extends StatefulWidget {
  final String? url;
  final String? localFile;
  final BoxConstraints constraints;

  const AudioMessage({
    Key? key,
    this.url,
    this.localFile,
    required this.constraints,
  }) : super(key: key);

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final player = AudioPlayer();
  late final ValueNotifier<Duration?> durationNotifier;
  late final Widget noise;

  @override
  void initState() {
    super.initState();
    noise = drawNoise(((widget.constraints.maxWidth - width) / 3.5).floor());
    if (widget.url != null) {
      player.setSource(UrlSource(widget.url!));
    } else {
      player.setSource(DeviceFileSource(widget.localFile!));
    }

    player.onPlayerComplete.listen((event) async {
      await player.stop();
    });
    durationNotifier = ValueNotifier(const Duration());
    player.onDurationChanged.listen((event) async {
      durationNotifier.value = await player.getDuration();
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    durationNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 240,
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: background,
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: player.onPlayerStateChanged,
            initialData: PlayerState.stopped,
            builder: (context, snap) {
              final state = snap.data as PlayerState;
              return Row(
                children: [
                  if (state == PlayerState.stopped ||
                      state == PlayerState.paused)
                    InkWell(
                      onTap: () async => {
                        await player.resume(),
                      },
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: gray,
                      ),
                    ),
                  if (state == PlayerState.playing)
                    InkWell(
                      onTap: () async => {
                        await player.pause(),
                      },
                      child: const Icon(
                        Icons.pause,
                        color: gray,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              noise,
              StreamBuilder<Duration>(
                stream: player.onPositionChanged,
                initialData: const Duration(seconds: 0),
                builder: (context, snap) {
                  final value = (snap.data as Duration).inMilliseconds;
                  var step = 0.0;
                  if (value != 0 &&
                      durationNotifier.value!.inMilliseconds != value) {
                    step = (widget.constraints.maxWidth - width) /
                        durationNotifier.value!.inMilliseconds *
                        value;
                  }
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: step,
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: primary,
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<Duration>(
                stream: player.onPositionChanged,
                initialData: const Duration(milliseconds: 0),
                builder: (context, snap) {
                  final value = (snap.data as Duration).inMilliseconds;

                  return Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      width: widget.constraints.maxWidth - width,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackShape: CustomTrackShape(),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: durationNotifier.value!.inMilliseconds.toDouble(),
                          onChanged: (value) => {
                            player.seek(Duration(milliseconds: value.toInt())),
                          },
                          value: value.toDouble(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder(
            valueListenable: durationNotifier,
            builder: (ctx, value, child) {
              final milliseconds = (value as Duration).inMilliseconds;
              final seconds = (milliseconds / 1000).ceil();

              final time = seconds < 10 ? '00:0$seconds' : '00:$seconds';
              return Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(.9),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget drawNoise(int count) {
    return Row(
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.only(right: 2),
          height: (Random().nextDouble() + 0.01) * 22,
          width: 1.5,
          color: gray,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
