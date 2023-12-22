import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class CEvent extends Event with EquatableMixin {
  @override
  final String name;

  const CEvent(this.name);

  @override
  List<Object?> get props => [name];
}

Event event1 = CEvent('event1');
Event event2 = CEvent('event2');

/// Make it `sealed` to have a finite number of states
sealed class MyState extends StateEvent<MyState> with EquatableMixin {
  String get id;
}

class Paused extends MyState {
  @override
  final void Function()? exit;

  Paused({this.exit});

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

class Playing extends MyState {
  @override
  String get id => "Playing";

  @override
  List<Object?> get props => [id];
}

class MockPaused extends Mock implements Paused {}

class MockMachine extends Mock implements Machine<MyState> {}

void main() {
  group('transition', () {
    test('state to state', () {
      final machine = Machine<MyState>(currentState: Paused());

      final newMachine = machine.transition(event1);

      expect(newMachine.currentState, Playing());
    });

    test('self-transition', () {
      final paused = Paused();
      final machine = Machine<MyState>(currentState: paused);

      final newMachine = machine.transition(event2);

      expect(newMachine.currentState, paused);
    });
  });

  group('entry/exit', () {
    test('exit action', () {
      int n = 0;
      final paused = Paused(exit: () => n += 1);
      final machine = Machine<MyState>(currentState: paused);

      machine.transition(event1);

      expect(n, 1);
    });
  });
}
