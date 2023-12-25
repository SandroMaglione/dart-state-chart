import 'dart:async';

import '../dart_state_chart.dart';

abstract class Streamable<Context, S extends CState<Context>> {
  Stream<S> get streamState;
  Stream<Context> get streamContext;
}

abstract class StateStreamable<Context, S extends CState<Context>>
    implements Streamable<Context, S> {
  S get state;
  Context get context;
}

abstract class Closable {
  FutureOr<void> close();
  bool get isClosed;
}

abstract class StateStreamableSource<Context, S extends CState<Context>>
    implements StateStreamable<Context, S>, Closable {}

abstract class Machine<Context, S extends CState<Context>,
    E extends Event<Context>> implements StateStreamableSource<Context, S> {
  Machine(this._state, this._context, this._events);

  final _stateController = StreamController<S>.broadcast();
  final _contextController = StreamController<Context>.broadcast();
  final Map<S, Map<E, S>> _events;

  S _state;
  Context _context;

  @override
  Context get context => _context;

  @override
  S get state => _state;

  @override
  Stream<S> get streamState => _stateController.stream;

  @override
  Stream<Context> get streamContext => _contextController.stream;

  @override
  bool get isClosed => _stateController.isClosed || _contextController.isClosed;

  void add(E event) {
    if (isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }

    final nextState = _events[_state]?[event];

    /// Current state does not have given outgoing [Event]
    if (nextState == null) return;

    /// Apply `exit` action for previous state
    final exitContext = _state.onExit?.call(context) ?? _context;

    if (exitContext != _context) {
      _contextController.add(exitContext);
      _context = exitContext;
    }

    /// Apply `event` action
    final action = event.action;
    final actionContext =
        action != null ? (action(_context) ?? _context) : _context;

    if (actionContext != _context) {
      _contextController.add(actionContext);
      _context = actionContext;
    }

    /// Apply `entry` action for upcoming state
    final entryContext = nextState.onEntry?.call(_context) ?? _context;

    if (entryContext != _context) {
      _contextController.add(entryContext);
      _context = entryContext;
    }

    _stateController.add(nextState);
    _state = nextState;
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    await _contextController.close();
  }
}
