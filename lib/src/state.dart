import 'package:dart_state_chart/src/event.dart';

abstract class State<Context> {
  Context? Function(Context context)? get entry;
  Context? Function(Context context)? get exit;

  Context? _onEntry(Context context) => entry?.call(context);
  Context? _onExit(Context context) => exit?.call(context);
}

abstract class StateEvent<Context, S extends State<Context>>
    extends State<Context> {
  @override
  Context? Function(Context context)? get entry => null;

  @override
  Context? Function(Context context)? get exit => null;

  Map<Event<Context>, S> get events => {};

  (S?, Context?) next(Event<Context> event, Context context) {
    final nextState = events[event];

    if (nextState != null && nextState != this) {
      final exitContext = _onExit(context) ?? context;
      final actionContext = event.action?.call(exitContext) ?? exitContext;
      final entryContext = nextState._onEntry(actionContext) ?? actionContext;
      return (nextState, entryContext);
    }

    return (nextState, null);
  }
}
