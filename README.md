# broadcast_stream_subscriber

A Dart mixin with a minimal set of methods to add and manage [StreamSubscription]s
and notify them of events with a broadcast (multi-stream) [StreamController].

# Usage

```dart
import 'package:broadcast_stream_subscriber/broadcast_stream_subscriber.dart';

// Mixin `BoradcastStreamSubscriber` to your class
class ClassName with BroadcastStreamSubscriber<T> {
  ClassName();

  // Dispose of your class
  void dispose() {
    // Cancel any still active `StreamSubscriptions`
    // and close the `StreamController`.
    closeStream();
  }
}

// Create an instance of your class
final ClassName _className = ClassName();

// Add a listener
_className.addListener((T event) {
  // Handle the event...
});

// Notify listeners of an event
_className.notifyListeners(eventData);

// Remove a listener
_className.removeListener();

// Dispose of your class. Alternatively call `ClassName.closeStream()` directly
// if nothing else from the class needs to be cancelled/closed/disposed.
_className.dispose();

```

## Using with Flutter

[BroadcastStreamSubscriber] can be used within Flutter widgets to listen for
events from any class that mixes it in.

To properly subscribe to events and dispose of the notifier when finished,
[BroadcastStreamSubscriber]'s methods should be implemented from within a
[StatefulWidget], or rather its [State].

```dart
  import 'package:flutter/material.dart';
  import 'package:broadcast_stream_subscriber/broadcast_stream_subscriber.dart';

  class ListenableClass with BroadcastStreamSubscriber<String> {
    ListenableClass();

    //

    void dispose() => closeStream();
  }

  class MyWidget extends StatefulWidget {
    @override
    _MyWidgetState createState() => _MyWidgetState();
  }

  class _MyWidgetState extends State<MyWidget> {
    final ListenableClass _listenableClass = ListenableClass();

    StreamSubscription<String> _onEvent;

    String _eventData;

    @override
    void initState() {
      super.initState();
      _listenForEvents();
    }

    @override
    void dispose() {
      _onEvent.cancel();
      _listenableClass.closeStream();
      super.dispose();
    }

    void _listenForEvents() {
      _onEvent = _listenableClass.addListener((String event) {
        setState(() => _eventData = event);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Text(_eventData ?? 'No event data recieved');
    }
  }
```

If a listenable class is inherited by a nested widget,
the [State]'s [didUpdateWidget] method should be utilized
to detect and handle any changes to the listener.

And, rather than calling [closeStream] on `dispose()`,
[removeListener] should instead be used. [closeStream]
should be called from within the parent.

```dart
  class MyWidget extends StatefulWidget {
    const MyWidget(this.listenableClass);

    final ListenableClass listenableClass;

    @override
    _MyWidgetState createState() => _MyWidgetState();
  }

  class _MyWidgetState extends State<MyWidget> {
    StreamSubscription<String> _onEvent;

    String _eventData;

    @override
    void initState() {
      super.initState();
      _listenForEvents();
    }

    @override
    void dispose() {
      _onEvent?.cancel();
      widget.listenableClass?.removeListener();
      super.dispose();
    }

    @override
    void didUpdateWidget(MyWidget old) {
      if (widget.listenableClass != old.listenableClass) {
        _onEvent?.cancel();
        _listenForEvents();
      }

      super.didUpdateWidget(old);
    }

    void _listenForEvents() {
      if (widget.listenableClass == null) return;

      _onEvent = widget.listenableClass.addListener((String event) {
        setState(() => _eventData = event);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Text(_eventData ?? 'No event data recieved');
    }
  }
```
