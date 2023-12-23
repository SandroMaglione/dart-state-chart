import 'package:dart_state_chart/src/event.dart';

abstract class State<Context> {
  void Function(Context context)? get entry;
  void Function(Context context)? get exit;

  void _onEntry(Context context) => entry?.call(context);
  void _onExit(Context context) => exit?.call(context);
}

abstract class StateEvent<Context, S extends State<Context>>
    extends State<Context> {
  @override
  void Function(Context context)? get entry => null;

  @override
  void Function(Context context)? get exit => null;

  Map<Event, S> get events => {};

  S? next(Event event, Context context) {
    final nextState = events[event];

    if (nextState != null && nextState != this) {
      _onExit(context);
      nextState._onEntry(context);
    }

    return nextState;
  }
}
