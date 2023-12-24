import '../dart_state_chart.dart';

class Event<Context, S extends StateEvent<Context, S>> {
  final String name;
  final Context? Function(Context context)? action;
  final S from;
  final S to;

  const Event(this.name, this.from, this.to, {this.action});

  S? nextState(S currentState) {
    if (currentState == from) return to;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event<Context, S> &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          from == other.from &&
          to == other.to &&
          action == other.action;

  @override
  int get hashCode =>
      name.hashCode ^ from.hashCode ^ to.hashCode ^ action.hashCode;

  @override
  String toString() {
    return '''Event { name: $name, from: $from, to:$to }''';
  }
}
