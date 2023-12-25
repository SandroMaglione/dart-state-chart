import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_machine/src/listener.dart';
import 'package:provider/provider.dart';

typedef MachineWidgetBuilder<Context, S extends CState<Context>> = Widget
    Function(BuildContext context, Context ctx, S state);

class MachineBuilder<M extends StateStreamable<Context, S>, Context,
    S extends CState<Context>> extends MachineBuilderBase<M, Context, S> {
  const MachineBuilder({
    required this.builder,
    Key? key,
    M? machine,
  }) : super(key: key, machine: machine);

  final MachineWidgetBuilder<Context, S> builder;

  @override
  Widget build(BuildContext context, Context ctx, S state) =>
      builder(context, ctx, state);
}

abstract class MachineBuilderBase<M extends StateStreamable<Context, S>,
    Context, S extends CState<Context>> extends StatefulWidget {
  const MachineBuilderBase({Key? key, this.machine}) : super(key: key);

  final M? machine;

  Widget build(BuildContext context, Context ctx, S state);

  @override
  State<MachineBuilderBase<M, Context, S>> createState() =>
      _MachineBuilderBaseState<M, Context, S>();
}

class _MachineBuilderBaseState<M extends StateStreamable<Context, S>, Context,
        S extends CState<Context>>
    extends State<MachineBuilderBase<M, Context, S>> {
  late M _machine;
  late S _state;
  late Context _context;

  @override
  void initState() {
    super.initState();
    _machine = widget.machine ?? context.read<M>();
    _state = _machine.state;
    _context = _machine.context;
  }

  @override
  void didUpdateWidget(MachineBuilderBase<M, Context, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMachine = oldWidget.machine ?? context.read<M>();
    final currentMachine = widget.machine ?? oldMachine;
    if (oldMachine != currentMachine) {
      _machine = currentMachine;
      _state = _machine.state;
      _context = _machine.context;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final machine = widget.machine ?? context.read<M>();
    if (_machine != machine) {
      _machine = machine;
      _state = _machine.state;
      _context = _machine.context;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MachineListener<M, Context, S>(
      machine: _machine,
      listener: (context, ctx, state) => setState(() {
        _state = state;
        _context = ctx;
      }),
      child: widget.build(context, _context, _state),
    );
  }
}
