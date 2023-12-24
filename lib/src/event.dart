class Event<Context> {
  final String name;
  final Context? Function(Context context)? action;

  const Event(this.name, {this.action});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event<Context> &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          action == other.action;

  @override
  int get hashCode => name.hashCode ^ action.hashCode;

  @override
  String toString() {
    return '''Event { name: $name }''';
  }
}
