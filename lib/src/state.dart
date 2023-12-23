import 'package:dart_state_chart/src/event.dart';

abstract class State<Context> {
  Context? Function(Context context)? entry;
  Context? Function(Context context)? exit;

  Context? _onEntry(Context context) => entry?.call(context);
  Context? _onExit(Context context) => exit?.call(context);
}

abstract class StateEvent<Context, S extends State<Context>>
    extends State<Context> {
  Map<Event<Context>, S> events = {};

  Stream<(S, Context)> next(
    Event<Context> event,
    S currentState,
    Context context,
  ) async* {
    final nextState = events[event];

    /// TODO: `nextState != this` does not handle self-transition, do it!
    if (nextState != null && nextState != this) {
      final exitContext = _onExit(context);
      if (exitContext != null) {
        yield (currentState, exitContext);
      }

      final afterExitContext = exitContext ?? context;
      final actionContext = event.action?.call(afterExitContext);
      if (actionContext != null) {
        yield (currentState, actionContext);
      }

      final afterActionContext = actionContext ?? afterExitContext;
      final entryContext = nextState._onEntry(afterActionContext);
      if (entryContext != null) {
        yield (currentState, entryContext);
      }

      final afterEntryContext = entryContext ?? afterActionContext;
      yield (nextState, afterEntryContext);
    }
  }
}
