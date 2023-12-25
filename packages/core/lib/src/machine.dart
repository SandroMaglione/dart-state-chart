import 'dart:async';

import '../dart_state_chart.dart';

abstract class Streamable<State extends Object?> {
  Stream<State> get stream;
}

abstract class StateStreamable<State> implements Streamable<State> {
  State get state;
}

abstract class Closable {
  FutureOr<void> close();
  bool get isClosed;
}

abstract class StateStreamableSource<State>
    implements StateStreamable<State>, Closable {}

abstract class Machine<Context, S extends CState<Context>,
    E extends Event<Context>> implements StateStreamableSource<S> {
  Machine(this._state, this._context, this._events);

  final _stateController = StreamController<S>.broadcast();
  final Map<S, Map<E, S>> _events;

  S _state;
  Context _context;

  Context get context => _context;

  @override
  S get state => _state;

  @override
  Stream<S> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  void add(E event) {
    if (isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }

    final nextState = _events[_state]?[event];
    if (nextState == null) return;

    /// Apply `exit` action for previous state
    final exitContext = _state.onExit?.call(context) ?? _context;
    _context = exitContext;

    /// Apply `event` action
    final action = event.action;
    final actionContext =
        action != null ? (action(_context) ?? _context) : _context;
    _context = actionContext;

    /// Apply `entry` action for upcoming state
    final entryContext = nextState.onEntry?.call(_context) ?? _context;
    _context = entryContext;

    _stateController.add(nextState);
    _state = nextState;
  }

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}
