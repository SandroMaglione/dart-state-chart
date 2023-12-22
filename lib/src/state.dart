import 'package:dart_state_chart/src/event.dart';

/// Shared methods for each state (no events)
abstract class State {
  void entry() {}
  void exit() {}
}

/// Add typed event transitions to a state
abstract class StateEvent<S extends State> extends State {
  Map<Event, S> get events => {};

  S? next(Event event) => events[event];
}
