// ignore_for_file: deprecated_member_use_from_same_package

part of 'bloc.dart';

const _asyncRunZoned = runZoned;

abstract class BlocOverrides {
  static final _token = Object();

  @Deprecated(
    'This will be removed in v9.0.0. Use Bloc.observer/Bloc.transformer instead.',
  )
  static BlocOverrides? get current => Zone.current[_token] as BlocOverrides?;

  @Deprecated(
    'This will be removed in v9.0.0. Use Bloc.observer/Bloc.transformer instead.',
  )
  static R runZoned<R>(
    R Function() body, {
    BlocObserver? blocObserver,
    EventTransformer<dynamic>? eventTransformer,
  }) {
    final overrides = _BlocOverridesScope(blocObserver, eventTransformer);
    return _asyncRunZoned(body, zoneValues: {_token: overrides});
  }

  @Deprecated('This will be removed in v9.0.0. Use Bloc.observer instead.')
  BlocObserver get blocObserver => Bloc.observer;

  @Deprecated('This will be removed in v9.0.0. Use Bloc.transformer instead.')
  EventTransformer<dynamic> get eventTransformer => Bloc.transformer;
}

class _BlocOverridesScope extends BlocOverrides {
  _BlocOverridesScope(this._blocObserver, this._eventTransformer);

  final BlocOverrides? _previous = BlocOverrides.current;
  final BlocObserver? _blocObserver;
  final EventTransformer<dynamic>? _eventTransformer;

  @override
  BlocObserver get blocObserver {
    final blocObserver = _blocObserver;
    if (blocObserver != null) return blocObserver;

    final previous = _previous;
    if (previous != null) return previous.blocObserver;

    return super.blocObserver;
  }

  @override
  EventTransformer<dynamic> get eventTransformer {
    final eventTransformer = _eventTransformer;
    if (eventTransformer != null) return eventTransformer;

    final previous = _previous;
    if (previous != null) return previous.eventTransformer;

    return super.eventTransformer;
  }
}
