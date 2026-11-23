import 'package:material_ui/material_ui.dart';
import 'dart:async';

class CountDownTimer extends StatefulWidget {
  final DateTime dateTime;
  final TextStyle? textStyle;
  const CountDownTimer({super.key, required this.dateTime, this.textStyle});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  // Set your date here
  late Timer _timer;
  late Duration _timeRemaining = widget.dateTime.difference(DateTime.now());

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = widget.dateTime.difference(DateTime.now());
        if (_timeRemaining.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int hours = _timeRemaining.inHours;
    int minutes = _timeRemaining.inMinutes.remainder(60);
    int seconds = _timeRemaining.inSeconds.remainder(60);
    if (!_timeRemaining.isNegative) {
      if (hours == 0) {
        return Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: widget.textStyle,
        );
      } else {
        return Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
          style: widget.textStyle,
        );
      }
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }
}
