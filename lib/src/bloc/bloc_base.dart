part of 'bloc.dart';

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

abstract class ErrorSink implements Closable {
  void addError(Object error, [StackTrace? stackTrace]);
}

abstract class BlocBase<State>
    implements StateStreamableSource<State>, Emittable<State>, ErrorSink {
  BlocBase(this._state) {
    _blocObserver.onCreate(this);
  }

  final _blocObserver = Bloc.observer;

  late final _stateController = StreamController<State>.broadcast();

  State _state;

  bool _emitted = false;

  @override
  State get state => _state;

  @override
  Stream<State> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  @protected
  @visibleForTesting
  @override
  void emit(State state) {
    try {
      if (isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }

      if (state == _state && _emitted) return;

      _state = state;
      _stateController.add(_state);
      _emitted = true;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    _blocObserver.onError(this, error, stackTrace);
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    _blocObserver.onClose(this);
    await _stateController.close();
  }
}
