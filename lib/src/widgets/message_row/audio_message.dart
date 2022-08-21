part of dash_chat_2;

const Color primary = Color(0xff15CCAB);
const Color gray = Color(0xA6000000);
const Color background = Color(0xD9F4F4F4);

const double width = 92;

class AudioMessage extends StatefulWidget {
  final String? url;
  final String? localFile;

  const AudioMessage({
    Key? key,
    this.url,
    this.localFile,
  }) : super(key: key);

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final player = AudioPlayer();
  late final ValueNotifier<Duration?> durationNotifier;
  var lastTiming = 0;

  @override
  void initState() {
    super.initState();
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
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 32,
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
                Noise(timeLineWidth: constraints.maxWidth - width),
                StreamBuilder<Duration>(
                  stream: player.onPositionChanged,
                  initialData: const Duration(seconds: 0),
                  builder: (context, position) {
                    return StreamBuilder(
                      stream: player.onPlayerStateChanged,
                      builder: (context, state) {
                        final value =
                            (position.data as Duration).inMilliseconds;
                        if (state.data == PlayerState.stopped) {
                          lastTiming = value;
                        }
                        var step = 0.0;
                        if (lastTiming != value) {
                          if (value != 0 && state.data != PlayerState.stopped) {
                            step = (constraints.maxWidth - width) /
                                durationNotifier.value!.inMilliseconds *
                                value;
                          }
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
                        width: constraints.maxWidth - width,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackShape: CustomTrackShape(),
                          ),
                          child: Slider(
                            min: 0.0,
                            max: durationNotifier.value!.inMilliseconds
                                .toDouble(),
                            onChanged: (value) => {
                              player
                                  .seek(Duration(milliseconds: value.toInt())),
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
                final allTime = (value as Duration).inMilliseconds;
                var seconds = (allTime / 1000).floor();
                var milliseconds = (allTime % 1000 / 100).ceil();
                if (milliseconds == 10) {
                  seconds += 1;
                  milliseconds = 0;
                }

                final time =
                    '${(seconds < 10) ? '0' : ''}$seconds,$milliseconds';
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
    });
  }
}

class Noise extends StatelessWidget {
  final double timeLineWidth;

  const Noise({
    Key? key,
    required this.timeLineWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 2),
            ...List.generate(
              (timeLineWidth / 3.5).ceil(),
              (index) => const Stick(),
            ),
          ],
        ),
      ),
    );
  }
}

class Stick extends StatelessWidget {
  const Stick({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      height: (Random().nextDouble() + 0.01) * 22,
      width: 1.5,
      color: gray,
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
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
