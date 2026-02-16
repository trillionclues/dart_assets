import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('should delay execution', () async {
      var called = false;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 100),
      );

      debouncer.call(() => called = true);

      expect(called, isFalse);
      await Future.delayed(const Duration(milliseconds: 150));
      expect(called, isTrue);

      debouncer.dispose();
    });

    test('should cancel previous calls', () async {
      var callCount = 0;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 100),
      );

      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, equals(1));

      debouncer.dispose();
    });
  });
}
