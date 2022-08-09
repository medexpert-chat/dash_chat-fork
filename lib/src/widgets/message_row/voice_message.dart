import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// ignore: library_prefixes
import 'package:just_audio/just_audio.dart' as jsAudio;
import 'package:voice_message_package/src/duration.dart';
import 'package:voice_message_package/src/helpers/utils.dart';
import 'dart:math' as math;

/// This is the main widget.
///
// ignore: must_be_immutable
class VoiceMessage extends StatefulWidget {
  VoiceMessage({
    Key? key,
    required this.audioSrc,
    this.noiseCount = 27,
    this.contactBgColor = const Color(0xffffffff),
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.meFgColor = const Color(0xffffffff),
    this.played = false,
    this.onPlay,
  }) : super(key: key);

  final String audioSrc;
  final int noiseCount;
  final Color meFgColor, contactBgColor, mePlayIconColor, contactPlayIconColor;
  final bool played;
  Function()? onPlay;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  Duration? _audioDuration;
  double maxDurationForSlider = .0000001;
  bool _isPlaying = false, x2 = false, _audioConfigurationDone = false;
  int _playingStatus = 0, duration = 00;
  String _remaingTime = '';
  AnimationController? _controller;

  @override
  void initState() {
    _setDuration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);

  Widget _sizerChild(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => !_audioConfigurationDone ? null : _changePlayingStatus(),
          child: Container(
            height: 32,
            width: 32,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: !_audioConfigurationDone
                ? const CircularProgressIndicator(
                    strokeWidth: 1,
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    size: 16,
                    color: Color(0xFF15CCAB),
                  ),
          ),
        ),
        SizedBox(width: 8),
        _noise(context),
      ],
    );
  }

  /// Noise widget of audio.
  _noise(BuildContext context) {
    return SizedBox(
      height: 25,
      width: noiseWidth,
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.hardEdge,
        children: [
          const CustomNoise(),
          if (_audioConfigurationDone)
            AnimatedBuilder(
              animation:
                  CurvedAnimation(parent: _controller!, curve: Curves.ease),
              builder: (context, child) {
                return Positioned(
                  left: _controller!.value,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          Opacity(
            opacity: 0.0,
            child: Slider(
              min: 0.0,
              max: maxDurationForSlider,
              onChanged: _onChangeSlider,
              value: duration + .0,
            ),
          ),
        ],
      ),
    );
  }

  _onChangeSlider(double d) async {
    duration = d.round();
    _controller?.value = (noiseWidth) * duration / maxDurationForSlider;
    _remaingTime = VoiceDuration.getDuration(duration);
    await _player.seek(Duration(seconds: duration));
    _player.resume();
    _controller?.forward();
    setState(() {});
  }

  _setPlayingStatus() => _isPlaying = _playingStatus == 1;

  _startPlaying() async {
    _playingStatus = await _player.play(widget.audioSrc);
    _setPlayingStatus();
    _controller!.forward();
  }

  _stopPlaying() async {
    _playingStatus = await _player.pause();
    _controller!.stop();
  }

  void _setDuration() async {
    _audioDuration = await jsAudio.AudioPlayer().setUrl(widget.audioSrc);
    duration = _audioDuration!.inSeconds;
    maxDurationForSlider = duration + .0;

    _player.onPlayerStateChanged.listen((event) {
      if (_player.state == PlayerState.COMPLETED) {
        _isPlaying = false;
        _controller!.value = 0;
        setState(() {});
      }
    });

    /// document will be added
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: _audioDuration,
    );

    /// document will be added
    _controller!.addListener(() {
      if (_controller!.isCompleted) {
        _controller!.reset();
        setState(() {});
      }
    });
    _setAnimationCunfiguration(_audioDuration);
  }

  void _setAnimationCunfiguration(Duration? audioDuration) async {
    _listenToRemaningTime();
    _remaingTime = VoiceDuration.getDuration(duration);
    _completeAnimationConfiguration();
  }

  void _completeAnimationConfiguration() =>
      setState(() => _audioConfigurationDone = true);

  void _changePlayingStatus() async {
    if (widget.onPlay != null) widget.onPlay!();
    _isPlaying ? _stopPlaying() : _startPlaying();
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _listenToRemaningTime() {
    _player.onAudioPositionChanged.listen((Duration p) {
      final _newRemaingTime1 = p.toString().split('.')[0];
      final _newRemaingTime2 =
          _newRemaingTime1.substring(_newRemaingTime1.length - 5);
      if (_newRemaingTime2 != _remaingTime) {
        setState(() => _remaingTime = _newRemaingTime2);
      }
    });
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
      margin: const EdgeInsets.only(right: 2),
      width: 4,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: const Color.fromRGBO(21, 204, 171, 0.45),
      ),
    );
  }
}
