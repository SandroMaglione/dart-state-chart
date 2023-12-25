import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

final class SemaphoreEvent extends Event<int> {
  const SemaphoreEvent._(super.name);

  static const green = SemaphoreEvent._('green');
  static const yellow = SemaphoreEvent._('yellow');
  static const red = SemaphoreEvent._('red');
}

final class SemaphoreEventWithAction extends Event<int> {
  const SemaphoreEventWithAction._(super.name, {super.action});

  static const green = SemaphoreEventWithAction._('green');
  static const yellow = SemaphoreEventWithAction._('yellow');
  static final red = SemaphoreEventWithAction._(
    'red',
    action: (ctx) => ctx + 1,
  );
}

sealed class SemaphoreState extends CState<int> with EquatableMixin {
  const SemaphoreState();

  @override
  List<Object?> get props => [];
}

class Green extends SemaphoreState {
  const Green._();
  static const state = Green._();
}

class Yellow extends SemaphoreState {
  const Yellow._();
  static const state = Yellow._();
}

class Red extends SemaphoreState {
  const Red._();
  static const state = Red._();
}

sealed class SemaphoreStateWithEntry extends CState<int> with EquatableMixin {
  const SemaphoreStateWithEntry();

  @override
  List<Object?> get props => [];
}

class GreenWithEntry extends SemaphoreStateWithEntry {
  const GreenWithEntry._();
  static const state = GreenWithEntry._();
}

class YellowWithEntry extends SemaphoreStateWithEntry {
  const YellowWithEntry._();
  static const state = YellowWithEntry._();
}

class RedWithEntry extends SemaphoreStateWithEntry {
  const RedWithEntry._();
  static const state = RedWithEntry._();
}

class SemaphoreMachine extends Machine<int, SemaphoreState, SemaphoreEvent> {
  SemaphoreMachine()
      : super(Green.state, 10, {
          Green.state: {
            SemaphoreEvent.yellow: Yellow.state,
          },
          Yellow.state: {
            SemaphoreEvent.red: Red.state,
          },
          Red.state: {
            SemaphoreEvent.green: Green.state,
          },
        });
}

class SemaphoreMachineWithActions
    extends Machine<int, SemaphoreStateWithEntry, SemaphoreEventWithAction> {
  SemaphoreMachineWithActions()
      : super(GreenWithEntry.state, 10, {
          GreenWithEntry.state: {
            SemaphoreEventWithAction.yellow: YellowWithEntry.state,
          },
          YellowWithEntry.state: {
            SemaphoreEventWithAction.red: RedWithEntry.state,
          },
          RedWithEntry.state: {
            SemaphoreEventWithAction.green: GreenWithEntry.state,
          },
        });
}

void main() {
  group('Machine', () {
    test('Green -> Yellow -> Red -> Green (no context change)', () async {
      final semaphoreMachine = SemaphoreMachine();
      final states = <SemaphoreState>[];
      final subscription = semaphoreMachine.streamState.listen(states.add);

      semaphoreMachine.add(SemaphoreEvent.yellow);
      semaphoreMachine.add(SemaphoreEvent.red);
      semaphoreMachine.add(SemaphoreEvent.green);

      await semaphoreMachine.close();
      await subscription.cancel();

      expect(states, [Yellow.state, Red.state, Green.state]);
      expect(semaphoreMachine.context, 10);
    });

    test('No transition when event does not exist in current state', () async {
      final semaphoreMachine = SemaphoreMachine();
      final states = <SemaphoreState>[];
      final subscription = semaphoreMachine.streamState.listen(states.add);

      semaphoreMachine.add(SemaphoreEvent.red); // 🙅‍♂️
      semaphoreMachine.add(SemaphoreEvent.green); // 🙅‍♂️
      semaphoreMachine.add(SemaphoreEvent.yellow);

      await semaphoreMachine.close();
      await subscription.cancel();

      expect(states, [Yellow.state]);
      expect(semaphoreMachine.context, 10);
    });

    test('Green -> Yellow -> Red -> Green (with action)', () async {
      final semaphoreMachine = SemaphoreMachineWithActions();
      final states = <SemaphoreStateWithEntry>[];
      final contexts = <int>[];
      final subscriptionS = semaphoreMachine.streamState.listen(states.add);
      final subscriptionC = semaphoreMachine.streamContext.listen(contexts.add);

      semaphoreMachine.add(SemaphoreEventWithAction.yellow);
      semaphoreMachine.add(SemaphoreEventWithAction.red);
      semaphoreMachine.add(SemaphoreEventWithAction.green);

      await semaphoreMachine.close();
      await subscriptionS.cancel();
      await subscriptionC.cancel();

      expect(
        states,
        [YellowWithEntry.state, RedWithEntry.state, GreenWithEntry.state],
      );
      expect(
        contexts,
        [11],
      );

      expect(semaphoreMachine.state, GreenWithEntry.state);
      expect(semaphoreMachine.context, 11);
    });
  });
}
