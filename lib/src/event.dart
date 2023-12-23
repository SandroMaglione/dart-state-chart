class Event<Context> {
  final String name;
  final Context? Function(Context context)? action;
  const Event(this.name, {this.action});
}
