part of 'machine.dart';

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

abstract class Emittable<State extends Object?> {
  void emit(State state);
}

abstract class MachineBase<Context, S extends StateEvent<Context, S>>
    implements StateStreamableSource<S>, Emittable<S> {
  MachineBase(this._state, this._context);

  late final _stateController = StreamController<S>.broadcast();

  S _state;
  Context _context;

  bool _emitted = false;

  @override
  S get state => _state;

  Context get context => _context;

  @override
  Stream<S> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  @override
  void emit(S state) {
    if (isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }

    if (state == _state && _emitted) return;

    final exitContext = _state.onExit(context) ?? _context;
    _context = exitContext;

    final entryContext = state.onEntry(exitContext) ?? exitContext;
    _context = entryContext;

    /// Keep track of current state by updating `_state`...
    _state = state;

    /// ...while also emitting `_state` to listeners
    _stateController.add(_state);
    _emitted = true;
  }

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}
