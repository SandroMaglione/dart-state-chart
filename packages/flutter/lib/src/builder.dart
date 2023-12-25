import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_machine/src/listener.dart';
import 'package:provider/provider.dart';

typedef MachineWidgetBuilder<S> = Widget Function(
    BuildContext context, S state);

typedef MachineBuilderCondition<S> = bool Function(S previous, S current);

class MachineBuilder<M extends StateStreamable<S>, S>
    extends MachineBuilderBase<M, S> {
  const MachineBuilder({
    required this.builder,
    Key? key,
    M? machine,
    MachineBuilderCondition<S>? buildWhen,
  }) : super(key: key, machine: machine, buildWhen: buildWhen);

  final MachineWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

abstract class MachineBuilderBase<M extends StateStreamable<S>, S>
    extends StatefulWidget {
  const MachineBuilderBase({Key? key, this.machine, this.buildWhen})
      : super(key: key);

  final M? machine;

  final MachineBuilderCondition<S>? buildWhen;

  Widget build(BuildContext context, S state);

  @override
  State<MachineBuilderBase<M, S>> createState() =>
      _MachineBuilderBaseState<M, S>();
}

class _MachineBuilderBaseState<M extends StateStreamable<S>, S>
    extends State<MachineBuilderBase<M, S>> {
  late M _machine;
  late S _state;

  @override
  void initState() {
    super.initState();
    _machine = widget.machine ?? context.read<M>();
    _state = _machine.state;
  }

  @override
  void didUpdateWidget(MachineBuilderBase<M, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.machine ?? context.read<M>();
    final currentBloc = widget.machine ?? oldBloc;
    if (oldBloc != currentBloc) {
      _machine = currentBloc;
      _state = _machine.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final machine = widget.machine ?? context.read<M>();
    if (_machine != machine) {
      _machine = machine;
      _state = _machine.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MachineListener<M, S>(
      machine: _machine,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }
}
