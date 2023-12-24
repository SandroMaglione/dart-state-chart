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

abstract class Machine<Context, S extends StateEvent<Context, S>>
    extends MachineBase<Context, S> {
  Machine(super._state, super._context, super._events);
}
