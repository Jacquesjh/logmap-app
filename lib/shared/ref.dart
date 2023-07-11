import 'package:flutter_riverpod/flutter_riverpod.dart';

class DummyNotifier extends Notifier<bool> {
  // This is necessary because the notification service is OUTSIDE of the
  // ProviderScope in the main.dart. We use this so give the notification service
  // access to the providers.
  //
  // https://stackoverflow.com/questions/72521691/riverpod-in-a-class-or-outside-of-build-method

  @override
  bool build() {
    refHolder = RefHolder._(ref);
    return true;
  }
}

final dummyProvider = NotifierProvider<DummyNotifier, bool>(() {
  return DummyNotifier();
});

late RefHolder refHolder;

class RefHolder {
  final Ref _ref;
  RefHolder._(this._ref);

  get ref {
    return _ref;
  }
}
