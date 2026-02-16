import 'dart:async';

// stops redundant processing when file saves trigger multiple events.
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
