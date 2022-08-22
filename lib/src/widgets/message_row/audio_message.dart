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

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      player.setUrl(widget.url!);
    } else {
      player.setFilePath(widget.localFile!);
    }

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        player.seek(const Duration(milliseconds: 0));
        player.stop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
          child: StreamBuilder<Duration?>(
            stream: player.durationStream,
            builder: (context, durationStream) {
              final duration = durationStream.data?.inMilliseconds ?? 0;

              return Row(
                children: [
                  PlayButton(player: player),
                  const SizedBox(width: 10),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Noise(timeLineWidth: constraints.maxWidth - width),
                      PlayerPosition(
                        player: player,
                        constraints: constraints,
                        duration: duration,
                      ),
                      PlayerRewind(
                        player: player,
                        constraints: constraints,
                        duration: duration,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  PlayerTime(
                    player: player,
                    duration: duration,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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

class PlayButton extends StatelessWidget {
  final AudioPlayer player;

  const PlayButton({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        if (snap.hasData) {
          final playingState = snap.data!.playing;
          return Row(
            children: [
              if (!playingState)
                InkWell(
                  onTap: () async => {
                    await player.play(),
                  },
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: gray,
                  ),
                ),
              if (playingState)
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
        }
        return Container();
      },
    );
  }
}

class PlayerPosition extends StatelessWidget {
  final AudioPlayer player;
  final BoxConstraints constraints;
  final int duration;

  const PlayerPosition({
    Key? key,
    required this.player,
    required this.constraints,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: player.positionStream,
      initialData: const Duration(milliseconds: 0),
      builder: (context, position) {
        final value = (position.data as Duration).inMilliseconds;
        double step = 0;
        if (value != 0 && value != duration) {
          step = (constraints.maxWidth - width) / duration * value;
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
  }
}

class PlayerRewind extends StatelessWidget {
  final AudioPlayer player;
  final BoxConstraints constraints;
  final int duration;

  const PlayerRewind({
    Key? key,
    required this.player,
    required this.constraints,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
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
                max: duration.toDouble(),
                onChanged: (value) => {
                  player.seek(
                    Duration(
                      milliseconds: value.toInt(),
                    ),
                  ),
                },
                value: value.toDouble(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlayerTime extends StatelessWidget {
  final AudioPlayer player;
  final int duration;

  const PlayerTime({
    Key? key,
    required this.player,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, position) {
        final currTime = position.data!.inMilliseconds;
        final time = (currTime == 0) ? duration : currTime;
        return Text(
          getTime(time),
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(.9),
          ),
        );
      },
    );
  }

  String getTime(int time) {
    var seconds = (time / 1000).floor();
    var milliseconds = (time % 1000 / 100).ceil();
    if (milliseconds == 10) {
      seconds += 1;
      milliseconds = 0;
    }

    return '${(seconds < 10) ? '0' : ''}$seconds,$milliseconds';
  }
}
