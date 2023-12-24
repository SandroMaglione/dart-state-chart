abstract class State<Context> {
  const State({this.onEntry, this.onExit});

  final Context? Function(Context ctx)? onEntry;
  final Context? Function(Context ctx)? onExit;

  @override
  String toString() {
    return '''State''';
  }
}
