import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const Color primary = Color(0xff15CCAB);
const Color palePrimary = Color.fromRGBO(21, 204, 171, 0.45);

class VoiceMessage extends StatefulWidget {
  final String audioSrc;

  const VoiceMessage({
    Key? key,
    required this.audioSrc,
  }) : super(key: key);

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  final AudioPlayer player = AudioPlayer();
  final double noiseWidth = 136;
  late final ValueNotifier<Duration?> durationNotifier;

  @override
  void initState() {
    player.setSource(UrlSource(widget.audioSrc));
    player.onPlayerComplete.listen((event) async {
      await player.stop();
    });
    durationNotifier = ValueNotifier(const Duration());
    player.onDurationChanged.listen((event) async {
      durationNotifier.value = await player.getDuration();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);

  Widget _sizerChild(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<PlayerState>(
          stream: player.onPlayerStateChanged,
          initialData: PlayerState.stopped,
          builder: (context, snap) {
            final state = snap.data as PlayerState;
            return Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state == PlayerState.stopped ||
                      state == PlayerState.paused)
                    InkWell(
                      onTap: () async => {
                        await player.resume(),
                      },
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: primary,
                      ),
                    ),
                  if (state == PlayerState.playing)
                    InkWell(
                      onTap: () async => {
                        await player.pause(),
                      },
                      child: const Icon(
                        Icons.pause,
                        color: primary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 25,
          width: noiseWidth,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.hardEdge,
            children: [
              const CustomNoise(),
              StreamBuilder<Duration>(
                stream: player.onPositionChanged,
                initialData: const Duration(seconds: 0),
                builder: (context, snap) {
                  final value = (snap.data as Duration).inMilliseconds;
                  var step = 0.0;
                  if (value != 0 &&
                      durationNotifier.value!.inMilliseconds != value) {
                    step = (noiseWidth /
                        durationNotifier.value!.inMilliseconds *
                        value);
                  }
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: step,
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<Duration>(
                stream: player.onPositionChanged,
                initialData: const Duration(milliseconds: 0),
                builder: (context, snap) {
                  var value = (snap.data as Duration).inMilliseconds;
                  if (value > durationNotifier.value!.inMilliseconds) {
                    value = durationNotifier.value!.inMilliseconds;
                  }

                  return Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      height: 25,
                      width: noiseWidth,
                      child: Slider(
                        min: 0.0,
                        max: durationNotifier.value!.inMilliseconds.toDouble(),
                        onChanged: (value) => {
                          player.seek(Duration(milliseconds: value.toInt())),
                        },
                        value: value.toDouble(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomNoise extends StatelessWidget {
  const CustomNoise({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [for (int i = 0; i < 17; i++) _singleNoise(context)],
    );
  }

  _singleNoise(BuildContext context) {
    final double height = (math.Random().nextDouble() + 0.1) * 24;
    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 4,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: palePrimary,
      ),
    );
  }
}
