abstract class State<Context> {
  Context? Function(Context context)? entry;
  Context? Function(Context context)? exit;

  Context? onEntry(Context context) => entry?.call(context);
  Context? onExit(Context context) => exit?.call(context);
}

abstract class StateEvent<Context, S extends State<Context>>
    extends State<Context> {}
