import 'package:dart_state_chart/src/event.dart';

/// Shared methods for each state (no events)
abstract class State {
  void Function()? get entry;
  void Function()? get exit;

  // Don't override!
  void _onEntry() {
    if (entry != null) {
      entry!();
    }
  }

  // Don't override!
  void _onExit() {
    if (exit != null) {
      exit!();
    }
  }
}

/// Adds typed event transitions to a state
abstract class StateEvent<S extends State> extends State {
  @override
  void Function()? get entry => null;

  @override
  void Function()? get exit => null;

  Map<Event, S> get events => {};

  S? next(Event event) {
    final nextState = events[event];

    if (nextState != null && nextState != this) {
      _onExit();
      nextState._onExit();
    }

    return nextState;
  }
}
