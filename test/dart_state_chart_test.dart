import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

typedef Context = int;

Event event1 = Event('event1');
Event event2 = Event('event2');

sealed class MyState extends StateEvent<Context, MyState> with EquatableMixin {
  String get id;
}

class Paused extends MyState {
  @override
  void Function(Context context)? entry;
  @override
  void Function(Context context)? exit;

  Paused({this.entry, this.exit});

  @override
  Map<Event, MyState> get events => {
        event1: Playing(),
        event2: this,
      };

  @override
  String get id => "Paused";

  @override
  List<Object?> get props => [id];
}

class Stopped extends MyState {
  @override
  Map<Event, MyState> events;

  Stopped(this.events);

  @override
  String get id => "Stopped";

  @override
  List<Object?> get props => [id];
}

class Playing extends MyState {
  @override
  String get id => "Playing";

  @override
  List<Object?> get props => [id];
}

class MockMachine extends Mock implements Machine<Context, MyState> {}

void main() {
  group('transition', () {
    test('state to state', () {
      final machine =
          Machine<Context, MyState>(currentState: Paused(), context: 0);

      machine.transition(event1);

      expect(machine.currentState, Playing());
    });

    test('self-transition', () {
      final paused = Paused();
      final machine =
          Machine<Context, MyState>(currentState: paused, context: 0);

      machine.transition(event2);

      expect(machine.currentState, paused);
    });
  });

  group('entry/exit', () {
    test('exit action', () {
      int n = 0;
      final paused = Paused(exit: (_) => n += 1);
      final machine =
          Machine<Context, MyState>(currentState: paused, context: 0);

      machine.transition(event1);

      expect(n, 1);
    });

    test('entry action', () {
      int n = 0;
      final event = Event('stp');

      final paused = Paused(entry: (_) => n += 1);
      final stopped = Stopped({event: paused});
      final machine =
          Machine<Context, MyState>(currentState: stopped, context: 0);

      machine.transition(event);

      expect(n, 1);
    });
  });

  group('context', () {
    test('read', () {
      int n = 0;
      final paused = Paused(exit: (context) => n = context);
      final machine =
          Machine<Context, MyState>(currentState: paused, context: 10);

      machine.transition(event1);

      expect(n, 10);
    });
  });
}
