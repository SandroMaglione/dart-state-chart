import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:test/test.dart';

typedef Context = ({int count});

sealed class States extends StateEvent<Context, States> {}

class Green extends States {
  @override
  Map<Event, States> get events => {
        Event('switch'): Yellow(),
      };
}

class Yellow extends States {
  @override
  Map<Event, States> get events => {
        Event('switch'): Red(),
      };
}

class Red extends States {
  @override
  Map<Event, States> get events => {
        Event('switch'): Green(),
      };
}

final machine = Machine<Context, States>(
  currentState: Green(),
  context: (count: 0),
);

void main() {
  group('semaphore', () {
    test('should switch from Green to Yellow', () {});
  });
}
