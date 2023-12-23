import 'package:dart_state_chart/src/event.dart';
import 'package:dart_state_chart/src/state.dart';

class Machine<Context, S extends StateEvent<Context, S>> {
  S currentState;
  Context context;

  Machine({required this.currentState, required this.context});

  void transition(Event<Context> event) {
    final (nextState, updateContext) = currentState.next(event, context);
    if (nextState != null) currentState = nextState;
    if (updateContext != null) context = updateContext;
  }
}
