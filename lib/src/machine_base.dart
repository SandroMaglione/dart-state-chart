import 'dart:async';

import '../dart_state_chart.dart';
import './machine_observer.dart';

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

class _DefaultMachineObserver extends MachineObserver {
  const _DefaultMachineObserver();
}

abstract class MachineBase<Context, S extends StateEvent<Context, S>>
    implements StateStreamableSource<S>, Emittable<S>, ErrorSink {
  MachineBase(this._state);

  final _machineObserver = const _DefaultMachineObserver();

  late final _stateController = StreamController<S>.broadcast();

  S _state;

  bool _emitted = false;

  @override
  S get state => _state;

  @override
  Stream<S> get stream => _stateController.stream;

  @override
  bool get isClosed => _stateController.isClosed;

  @override
  void emit(S state) {
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

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  void onError(Object error, StackTrace stackTrace) {
    _machineObserver.onError(this, error, stackTrace);
  }

  @override
  Future<void> close() async {
    _machineObserver.onClose(this);
    await _stateController.close();
  }
}
