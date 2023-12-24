import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

final class SemaphoreEvent extends Event<int> {
  const SemaphoreEvent._(super.name);

  static final green = SemaphoreEvent._('green');
  static final yellow = SemaphoreEvent._('yellow');
  static final red = SemaphoreEvent._('red');
}

final class SemaphoreEventWithAction extends Event<int> {
  const SemaphoreEventWithAction._(super.name, {super.action});

  static final green = SemaphoreEventWithAction._('green');
  static final yellow =
      SemaphoreEventWithAction._('yellow', action: (ctx) => ctx + 1);
  static final red = SemaphoreEventWithAction._('red');
}

sealed class SemaphoreState extends StateEvent<int, SemaphoreState>
    with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class Green extends SemaphoreState {}

class Yellow extends SemaphoreState {}

class Red extends SemaphoreState {}

class SemaphoreMachine extends Machine<int, SemaphoreState, SemaphoreEvent> {
  SemaphoreMachine()
      : super(Green(), 10, {
          Green(): {
            SemaphoreEvent.yellow: Yellow(),
          },
          Yellow(): {
            SemaphoreEvent.red: Red(),
          },
          Red(): {
            SemaphoreEvent.green: Green(),
          },
        });
}

class SemaphoreMachineWithActions
    extends Machine<int, SemaphoreState, SemaphoreEventWithAction> {
  SemaphoreMachineWithActions()
      : super(Green(), 10, {
          Green(): {
            SemaphoreEventWithAction.yellow: Yellow(),
          },
          Yellow(): {
            SemaphoreEventWithAction.red: Red(),
          },
          Red(): {
            SemaphoreEventWithAction.green: Green(),
          },
        });
}

void main() {
  group('Machine', () {
    test('Green -> Yellow -> Red -> Green (no context change)', () async {
      final semaphoreMachine = SemaphoreMachine();
      final states = <SemaphoreState>[];
      final subscription = semaphoreMachine.stream.listen(states.add);

      semaphoreMachine.add(SemaphoreEvent.yellow);
      semaphoreMachine.add(SemaphoreEvent.red);
      semaphoreMachine.add(SemaphoreEvent.green);

      await semaphoreMachine.close();
      await subscription.cancel();

      expect(states, [Yellow(), Red(), Green()]);
      expect(semaphoreMachine.context, 10);
    });

    test('Green -> Yellow -> Red -> Green (onEntry)', () async {
      final semaphoreMachine = SemaphoreMachineWithActions();
      final states = <SemaphoreState>[];
      final subscription = semaphoreMachine.stream.listen(states.add);

      semaphoreMachine.add(SemaphoreEventWithAction.yellow);
      semaphoreMachine.add(SemaphoreEventWithAction.red);
      semaphoreMachine.add(SemaphoreEventWithAction.green);

      await semaphoreMachine.close();
      await subscription.cancel();

      expect(states, [Yellow(), Red(), Green()]);
      expect(semaphoreMachine.context, 11);
    });
  });
}
