import 'dart:async';

import 'package:dart_state_chart/src/event.dart';
import 'package:dart_state_chart/src/state.dart';

class Machine<Context, S extends StateEvent<Context, S>> {
  S currentState;
  Context context;

  final _controller = StreamController<(S, Context)>.broadcast();

  Machine({required this.currentState, required this.context}) {
    subscribe.listen((event) {
      currentState = event.$1;
      context = event.$2;
    });
  }

  Future<void> transition(Event<Context> event) async =>
      _controller.sink.addStream(
        currentState.next(event, currentState, context),
      );

  Stream<(S, Context)> get subscribe => _controller.stream;
}
