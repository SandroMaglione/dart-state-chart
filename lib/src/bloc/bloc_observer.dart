import 'package:dart_state_chart/src/bloc/bloc.dart';
import 'package:dart_state_chart/src/bloc/transition.dart';
import 'package:meta/meta.dart';

abstract class BlocObserver {
  const BlocObserver();

  @protected
  @mustCallSuper
  void onCreate(BlocBase<dynamic> bloc) {}

  @protected
  @mustCallSuper
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {}

  @protected
  @mustCallSuper
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {}

  @protected
  @mustCallSuper
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {}

  @protected
  @mustCallSuper
  void onClose(BlocBase<dynamic> bloc) {}
}
