import 'package:dart_state_chart/src/event.dart';
import 'package:dart_state_chart/src/state.dart';

class Machine<S extends StateEvent<S>> {
  final S currentState;

  const Machine({required this.currentState});

  Machine<S> transition(Event event) => Machine<S>(
        currentState: currentState.next(event) ?? currentState,
      );
}
