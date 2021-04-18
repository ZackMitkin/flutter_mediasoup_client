import 'package:eventify/eventify.dart';

class EnhancedEventEmitter extends EventEmitter {
  safeEmit(String event, {args}) {
    emit('event', args);
  }
}
