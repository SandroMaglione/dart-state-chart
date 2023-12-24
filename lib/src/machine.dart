import 'dart:async';

import 'package:dart_state_chart/src/event.dart';
import 'package:dart_state_chart/src/state.dart';

part 'emitter.dart';
part 'machine_base.dart';

typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> emit,
);

typedef EventMapper<Event> = Stream<Event> Function(Event event);

typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event> events,
  EventMapper<Event> mapper,
);

abstract class MachineEventSink<Context, S extends StateEvent<Context, S>> {
  void add(Event<Context, S> event);
}

abstract class Machine<Context, S extends StateEvent<Context, S>>
    extends MachineBase<Context, S> implements MachineEventSink<Context, S> {
  Machine(super._state, super._context, this.events) {
    _eventController.stream.listen((event) {
      final nextState = events.lookup(event)?.nextState(_state);
      if (nextState != null) emit(nextState);
    });
  }

  Set<Event<Context, S>> events;

  final _eventController = StreamController<Event<Context, S>>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  void add(Event<Context, S> event) {
    _eventController.add(event);
  }

  @override
  Future<void> close() async {
    await _eventController.close();

    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    return super.close();
  }
}
