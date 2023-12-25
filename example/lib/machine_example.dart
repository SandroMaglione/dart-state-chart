import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:equatable/equatable.dart';

final class SemaphoreEvent extends Event<int> {
  const SemaphoreEvent._(super.name, {super.action});

  static const green = SemaphoreEvent._('green');
  static const yellow = SemaphoreEvent._('yellow');
  static final red = SemaphoreEvent._(
    'red',
    action: (ctx) => ctx + 1,
  );
}

sealed class SemaphoreState extends CState<int> with EquatableMixin {
  const SemaphoreState();

  @override
  List<Object?> get props => [];
}

class Green extends SemaphoreState {
  const Green._();
  static const state = Green._();
}

class Yellow extends SemaphoreState {
  const Yellow._();
  static const state = Yellow._();
}

class Red extends SemaphoreState {
  const Red._();
  static const state = Red._();
}

class SemaphoreMachine extends Machine<int, SemaphoreState, SemaphoreEvent> {
  SemaphoreMachine()
      : super(Green.state, 10, {
          Green.state: {
            SemaphoreEvent.yellow: Yellow.state,
          },
          Yellow.state: {
            SemaphoreEvent.red: Red.state,
          },
          Red.state: {
            SemaphoreEvent.green: Green.state,
          },
        });
}
