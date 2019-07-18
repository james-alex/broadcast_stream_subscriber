import 'dart:async';
import 'package:test/test.dart';
import 'package:broadcast_stream_subscriber/broadcast_stream_subscriber.dart';

void main() {
  final _testString = 'Event test';

  String _eventTest;

  test('BroadcastStreamSubscriber mixes in methods to manage streams on a class.', () async {
    // Initialize a class to test the mixed in methods.
    final _BroadcastStreamSubscriberTest test = _BroadcastStreamSubscriberTest();

    // Add a listener and do something with the event data
    test.addListener((String event) => _eventTest = event);

    // Confirm the listener was added
    expect(test.updateNotifier.hasListener, equals(true));

    // Notify the listener
    test.notifyListeners(_testString);

    // Wait 50ms so the listener can be notified
    await Future.delayed(const Duration(milliseconds: 50), (){});

    // Confirm the listener was notified by checking the variable set by it's event data
    expect(_eventTest, equals(_testString));

    // Remove the listener and close the stream
    test.closeStream();

    // Confirm the stream was closed
    expect(test.updateNotifier.isClosed, equals(true));
  });
}

/// An empty class that can be subscribed and listened to
class _BroadcastStreamSubscriberTest with BroadcastStreamSubscriber<String> {
  _BroadcastStreamSubscriberTest();
}
