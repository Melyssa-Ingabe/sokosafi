import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds [builder] with the current time at a regular interval, for
/// labels that count down such as "In 2h". Stateful only to own the timer.
class NowTicker extends StatefulWidget {
  const NowTicker({
    super.key,
    required this.builder,
    this.interval = const Duration(seconds: 30),
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;

  @override
  State<NowTicker> createState() => _NowTickerState();
}

class _NowTickerState extends State<NowTicker> {
  late final Stream<DateTime> _ticks = Stream<DateTime>.periodic(
    widget.interval,
    (_) => DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    // The stream is created once, so a parent rebuild does not restart it.
    return StreamBuilder<DateTime>(
      stream: _ticks,
      builder: (context, snapshot) =>
          widget.builder(context, snapshot.data ?? DateTime.now()),
    );
  }
}
