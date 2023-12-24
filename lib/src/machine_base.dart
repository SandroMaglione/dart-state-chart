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

abstract class Emittable<Context> {
  void emit(Event<Context> event);
}

abstract class MachineBase<Context, S extends StateEvent<Context, S>>
    implements StateStreamableSource<S>, Emittable<Context> {
  MachineBase(this._state, this._context, this.events);

  late final _stateController = StreamController<S>.broadcast();

  S _state;
  Context _context;

  final Map<S, Map<Event<Context>, S>> events;

  bool _emitted = false;

  @override
  S get state => _state;

  Context get context => _context;

  @override
  Stream<S> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  @override
  void emit(Event<Context> event) {
    if (isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }
    final nextState = events[_state]?[event];

    if (nextState == null || (nextState == _state && _emitted)) return;

    final exitContext = _state.onExit(context) ?? _context;
    _context = exitContext;

    final entryContext = nextState.onEntry(exitContext) ?? exitContext;
    _context = entryContext;

    _stateController.add(nextState);
    _state = nextState;
    _emitted = true;
  }

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}
