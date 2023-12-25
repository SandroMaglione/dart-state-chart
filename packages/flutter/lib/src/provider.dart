import 'package:dart_state_chart/dart_state_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MachineProvider<T extends StateStreamableSource<Object?>>
    extends SingleChildStatelessWidget {
  const MachineProvider({
    required Create<T> create,
    Key? key,
    this.child,
    this.lazy = true,
  })  : _create = create,
        super(key: key, child: child);

  final Widget? child;

  final bool lazy;

  final Create<T>? _create;

  static T of<T extends StateStreamableSource<Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError('''Context that does not contain a $T.''');
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return InheritedProvider<T>(
      create: _create,
      dispose: (_, machine) => machine.close(),
      startListening: _startListening,
      lazy: lazy,
      child: child,
    );
  }

  static VoidCallback _startListening(
    InheritedContext<StateStreamable<dynamic>?> e,
    StateStreamable<dynamic> value,
  ) {
    final subscription = value.stream.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}
