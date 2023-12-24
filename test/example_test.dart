import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

abstract class EventCollection {
  static final yellow = Event<int>('yellow');
  static final red = Event<int>('red');
  static final green = Event<int>('green');
}

sealed class SemaphoreState extends StateEvent<int, SemaphoreState>
    with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class Green extends SemaphoreState {}

class Yellow extends SemaphoreState {}

class Red extends SemaphoreState {}

class SemaphoreMachine extends Machine<int, SemaphoreState> {
  SemaphoreMachine()
      : super(Green(), 10, {
          Green(): {
            EventCollection.yellow: Yellow(),
          },
          Yellow(): {
            EventCollection.red: Red(),
          },
          Red(): {
            EventCollection.green: Green(),
          },
        });
}

void main() {
  group('Machine', () {
    test('Yellow -> Red -> Green', () async {
      final semaphoreMachine = SemaphoreMachine();
      final states = <SemaphoreState>[];
      final subscription = semaphoreMachine.stream.listen(states.add);

      semaphoreMachine.emit(EventCollection.yellow);
      semaphoreMachine.emit(EventCollection.red);
      semaphoreMachine.emit(EventCollection.green);

      await semaphoreMachine.close();
      await subscription.cancel();

      expect(states, [Yellow(), Red(), Green()]);
    });
  });
}
