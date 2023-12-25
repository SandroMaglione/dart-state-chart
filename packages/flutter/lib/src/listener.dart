import 'dart:async';

import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef MachineWidgetListener<S> = void Function(BuildContext context, S state);

typedef MachineListenerCondition<S> = bool Function(S previous, S current);

class MachineListener<M extends StateStreamable<S>, S>
    extends MachineListenerBase<M, S> {
  const MachineListener({
    required MachineWidgetListener<S> listener,
    Key? key,
    M? machine,
    MachineListenerCondition<S>? listenWhen,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          machine: machine,
          listenWhen: listenWhen,
        );
}

abstract class MachineListenerBase<M extends StateStreamable<S>, S>
    extends SingleChildStatefulWidget {
  const MachineListenerBase({
    required this.listener,
    Key? key,
    this.machine,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  final Widget? child;

  final M? machine;

  final MachineWidgetListener<S> listener;

  final MachineListenerCondition<S>? listenWhen;

  @override
  SingleChildState<MachineListenerBase<M, S>> createState() =>
      _MachineListenerBaseState<M, S>();
}

class _MachineListenerBaseState<M extends StateStreamable<S>, S>
    extends SingleChildState<MachineListenerBase<M, S>> {
  StreamSubscription<S>? _subscription;
  late M _machine;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _machine = widget.machine ?? context.read<M>();
    _previousState = _machine.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(MachineListenerBase<M, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.machine ?? context.read<M>();
    final currentBloc = widget.machine ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _machine = currentBloc;
        _previousState = _machine.state;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.machine ?? context.read<M>();
    if (_machine != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _machine = bloc;
        _previousState = _machine.state;
      }
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _machine.stream.listen((state) {
      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
