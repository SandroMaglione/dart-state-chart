part of 'bloc.dart';

abstract class Streamable<State> {
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

abstract class BlocBase<State>
    implements StateStreamableSource<State>, Emittable<State> {
  BlocBase(this._state);

  late final _stateController = StreamController<State>.broadcast();

  State _state;

  bool _emitted = false;

  @override
  State get state => _state;

  @override
  Stream<State> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  @override
  void emit(State state) {
    if (isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }

    if (state == _state && _emitted) return;

    _state = state;
    _stateController.add(_state);
    _emitted = true;
  }

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}
