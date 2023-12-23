import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:dart_state_chart/src/machine_base.dart';
import 'package:meta/meta.dart';

abstract class MachineObserver {
  const MachineObserver();

  @protected
  @mustCallSuper
  void onTransition(MachineBase machine, Event event) {}

  @protected
  @mustCallSuper
  void onError(MachineBase machine, Object error, StackTrace stackTrace) {}

  @protected
  @mustCallSuper
  void onClose(MachineBase machine) {}
}
