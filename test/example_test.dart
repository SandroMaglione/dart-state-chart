import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

abstract class EventCollection {
  static final yellow = Event<int, SemaphoreState>(
    'yellow',
    Green(),
    Yellow(),
  );

  static final red = Event<int, SemaphoreState>(
    'red',
    Yellow(),
    Red(),
  );

  static final green = Event<int, SemaphoreState>(
    'green',
    Red(),
    Green(),
  );
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
          EventCollection.yellow,
        });
}

void main() {
  group('Machine', () {
    test('Yellow -> Red -> Green', () {
      final semaphoreMachine = SemaphoreMachine();

      expectLater(
        semaphoreMachine.stream,
        emitsInOrder([Yellow(), Red(), Green(), emitsDone]),
      ).then((_) {
        expect(semaphoreMachine.state, Green());
      });

      semaphoreMachine
        ..add(EventCollection.yellow)
        ..add(EventCollection.red)
        ..add(EventCollection.green)
        ..close();
    });
  });
}
