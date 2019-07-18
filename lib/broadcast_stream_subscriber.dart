library broadcast_stream_subscriber;

import 'dart:async';

/// A minimal set of mixin methods to add and manage
/// [StreamSubscription]s on any class.
///
/// Once mixed into a class, listeners can be created and removed with
/// the [addListener] and [removeListener] methods respectively.
///
/// Call [notifyListeners] to notify all listeners of any of an event
/// and optionally pass [event] data down the [StreamSink].
///
/// The [StreamController] is created once on init as [updateNotifier].
/// Once closed, it cannot be reopened.
///
/// Any class that mixes in [BroadcastStreamSubscriber]
/// should call `closeStream()` when it is no longer needed,
/// or when the class is disposed of.
mixin BroadcastStreamSubscriber<T> {
  /// The list of active [StreamSubscription]s.
  final List<StreamSubscription<T>> _subscriptions =
    <StreamSubscription<T>>[];

  /// A broadcast stream [StreamController].
  ///
  /// It is not reccomended to add and remove subscriptions directly.
  /// Instead, use the [addListener] and [removeListener] methods.
  final StreamController<T> updateNotifier =
    StreamController<T>.broadcast();

  /// Creates, stores and returns a [StreamSubscription].
  StreamSubscription<T> addListener(void onUpdate(T event)) {
    _subscriptions.add(
      updateNotifier.stream.asBroadcastStream().listen(onUpdate),
    );

    return _subscriptions.last;
  }

  /// Cancels and removes a [StreamSubscription].
  void removeListener() {
    _subscriptions.last.cancel();
    _subscriptions.removeLast();
  }

  /// Notifies all subscribed listeners of an event.
  ///
  /// Optionally add [event] data to the [StreamSink].
  ///
  /// [event] is `null` by default.
  ///
  /// Wraps `StreamController.sink.add(event)`.
  void notifyListeners([T event]) {
    updateNotifier.sink.add(event);
  }

  /// Cancels any active [StreamSubscription]s and closes [updateNotifier].
  void closeStream() {
    _subscriptions.forEach(
      (StreamSubscription<T> subscription) => subscription.cancel(),
    );

    updateNotifier.close();
  }
}
