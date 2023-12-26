typedef StateAction<Context> = Context? Function(Context ctx)?;

abstract class CState<Context> {
  const CState({this.onEntry, this.onExit});

  final StateAction<Context> onEntry;
  final StateAction<Context> onExit;

  @override
  String toString() {
    return '''CState''';
  }
}
