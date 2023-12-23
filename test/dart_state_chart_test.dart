import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

typedef Context = int;

Event<Context> event1 = Event('event1');
Event<Context> event2 = Event('event2');

sealed class MyState extends StateEvent<Context, MyState> with EquatableMixin {
  String get id;
}

class Paused extends MyState {
  Paused();

  @override
  Map<Event<Context>, MyState> get events => {
        event1: Playing(),
        event2: this,
      };

  @override
  String get id => "Paused";

  @override
  List<Object?> get props => [id];
}

class Running extends MyState {
  Running();

  @override
  String get id => "Running";

  @override
  List<Object?> get props => [id];
}

class Stopped extends MyState {
  Stopped();

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

void main() {
  // group('transition', () {
  //   test('state to state', () {
  //     final machine =
  //         Machine<Context, MyState>(currentState: Paused(), context: 0);

  //     machine.transition(event1);

  //     expect(machine.currentState, Playing());
  //   });

  //   test('self-transition', () {
  //     final paused = Paused();
  //     final machine =
  //         Machine<Context, MyState>(currentState: paused, context: 0);

  //     machine.transition(event2);

  //     expect(machine.currentState, paused);
  //   });
  // });

  // group('entry/exit', () {
  //   test('exit action', () {
  //     int n = 0;
  //     final paused = Paused()..exit = (_) => n += 1;
  //     final machine =
  //         Machine<Context, MyState>(currentState: paused, context: 0);

  //     machine.transition(event1);

  //     expect(n, 1);
  //   });

  //   test('entry action', () {
  //     int n = 0;
  //     final event = Event<Context>('stp');

  //     final paused = Paused()..entry = (_) => n += 1;
  //     final stopped = Stopped({event: paused});
  //     final machine =
  //         Machine<Context, MyState>(currentState: stopped, context: 0);

  //     machine.transition(event);

  //     expect(n, 1);
  //   });
  // });

  // group('context', () {
  //   test('read', () {
  //     int n = 0;
  //     final paused = Paused()..exit = (context) => n = context;
  //     final machine =
  //         Machine<Context, MyState>(currentState: paused, context: 10);

  //     machine.transition(event1);

  //     expect(n, 10);
  //   });

  //   test('update on exit', () {
  //     final paused = Paused()..exit = (context) => context + 1;
  //     final machine =
  //         Machine<Context, MyState>(currentState: paused, context: 10);

  //     machine.transition(event1);

  //     expect(machine.context, 11);
  //   });

  //   test('update on entry', () {
  //     final event = Event<Context>('stp');

  //     final paused = Paused()..entry = (context) => context + 1;
  //     final stopped = Stopped({event: paused});
  //     final machine =
  //         Machine<Context, MyState>(currentState: stopped, context: 10);

  //     machine.transition(event);

  //     expect(machine.context, 11);
  //   });
  // });

  // group('event action', () {
  //   test('read', () {
  //     int n = 0;

  //     final event = Event<Context>('some', action: (context) => n = context);
  //     final paused = Paused();
  //     final stopped = Stopped({event: paused});
  //     final machine =
  //         Machine<Context, MyState>(currentState: stopped, context: 10);

  //     machine.transition(event);

  //     expect(n, 10);
  //   });

  //   test('update action', () {
  //     final event = Event<Context>('some', action: (context) => context + 1);
  //     final paused = Paused();
  //     final stopped = Stopped({event: paused});
  //     final machine =
  //         Machine<Context, MyState>(currentState: stopped, context: 10);

  //     machine.transition(event);

  //     expect(machine.context, 11);
  //   });
  // });

  group('stream', () {
    test('subscribe', () {
      final paused = Paused()..exit = (context) => context + 1;
      final machine = Machine<Context, MyState>(
        currentState: paused,
        context: 0,
      );

      machine.transition(event1);

      expectLater(
        machine.subscribe,
        emitsInOrder(
          [(paused, 1), (Playing(), 1)],
        ),
      );
    });

    test('double event', () async {
      final eventRs = Event<Context>('rs');
      final eventSr = Event<Context>('sr');

      final running = Running();
      final stopped = Stopped();

      running.events = {eventRs: stopped};
      stopped.events = {eventSr: running};
      final machine = Machine<Context, MyState>(
        currentState: stopped,
        context: 0,
      );

      await machine.transition(eventSr);
      await machine.transition(eventRs);

      expectLater(
        machine.subscribe,
        emitsInOrder(
          [(running, 0), (stopped, 0)],
        ),
      );
    });
  });
}
