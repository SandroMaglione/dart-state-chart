import 'dart:async';

import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef MachineWidgetListener<Context, S extends CState<Context>> = void
    Function(BuildContext context, Context ctx, S state);

class MachineListener<M extends StateStreamable<Context, S>, Context,
    S extends CState<Context>> extends MachineListenerBase<M, Context, S> {
  const MachineListener({
    required MachineWidgetListener<Context, S> listener,
    Key? key,
    M? machine,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          machine: machine,
        );
}

abstract class MachineListenerBase<M extends StateStreamable<Context, S>,
    Context, S extends CState<Context>> extends SingleChildStatefulWidget {
  const MachineListenerBase({
    required this.listener,
    Key? key,
    this.machine,
    this.child,
  }) : super(key: key, child: child);

  final Widget? child;

  final M? machine;

  final MachineWidgetListener<Context, S> listener;

  @override
  SingleChildState<MachineListenerBase<M, Context, S>> createState() =>
      _MachineListenerBaseState<M, Context, S>();
}

class _MachineListenerBaseState<M extends StateStreamable<Context, S>, Context,
        S extends CState<Context>>
    extends SingleChildState<MachineListenerBase<M, Context, S>> {
  StreamSubscription<S>? _subscriptionState;
  StreamSubscription<Context>? _subscriptionContext;

  late M _machine;
  late S _previousState;
  late Context _previousContext;

  @override
  void initState() {
    super.initState();
    _machine = widget.machine ?? context.read<M>();
    _previousState = _machine.state;
    _previousContext = _machine.context;
    _subscribeState();
    _subscribeContext();
  }

  @override
  void didUpdateWidget(MachineListenerBase<M, Context, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMachine = oldWidget.machine ?? context.read<M>();
    final currentMachine = widget.machine ?? oldMachine;

    if (oldMachine != currentMachine) {
      if (_subscriptionState != null) {
        _unsubscribeState();
        _machine = currentMachine;
        _previousState = _machine.state;
      }

      if (_subscriptionContext != null) {
        _unsubscribeContext();
        _machine = currentMachine;
        _previousContext = _machine.context;
      }

      _subscribeContext();
      _subscribeState();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final machine = widget.machine ?? context.read<M>();
    if (_machine != machine) {
      if (_subscriptionState != null) {
        _unsubscribeState();
        _machine = machine;
        _previousState = _machine.state;
      }

      if (_subscriptionContext != null) {
        _unsubscribeContext();
        _machine = machine;
        _previousContext = _machine.context;
      }

      _subscribeContext();
      _subscribeState();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
  }

  @override
  void dispose() {
    _unsubscribeState();
    super.dispose();
  }

  void _subscribeState() {
    _subscriptionState = _machine.streamState.listen((state) {
      widget.listener(context, _previousContext, state);
      _previousState = state;
    });
  }

  void _unsubscribeState() {
    _subscriptionState?.cancel();
    _subscriptionState = null;
  }

  void _subscribeContext() {
    _subscriptionContext = _machine.streamContext.listen((newContext) {
      widget.listener(context, newContext, _previousState);
      _previousContext = newContext;
    });
  }

  void _unsubscribeContext() {
    _subscriptionContext?.cancel();
    _subscriptionContext = null;
  }
}
