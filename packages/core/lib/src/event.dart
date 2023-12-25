typedef EventAction<Context> = Context? Function(Context ctx)?;

abstract class Event<Context> {
  final String name;
  final EventAction<Context> action;

  const Event(this.name, {this.action});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event<Context> &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return '''Event { name: $name }''';
  }
}
