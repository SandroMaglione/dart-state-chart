import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

class CEvent extends Event with EquatableMixin {
  @override
  final String name;

  const CEvent(this.name);

  @override
  List<Object?> get props => [name];
}

Event event = CEvent('event1');

/// Make it `sealed` to have a finite number of states
sealed class MyState extends StateEvent<MyState> with EquatableMixin {
  String get id;
}

class Paused extends MyState {
  @override
  Map<Event, MyState> get events => {
        event: Playing(),
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

void main() {
  test('transition', () {
    Machine<MyState> machine = Machine(currentState: Paused());
    final newMachine = machine.transition(event);
    expect(newMachine.currentState, Playing());
  });
}
