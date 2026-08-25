import 'package:ts_driver/app/native_calling/enums/native_calling_events.dart';

class NativeCallingEvent {
  NativeCallingEvents event;
  dynamic data;

  NativeCallingEvent(this.event, this.data);
  @override
  String toString() => 'CallEvent( body: $data, event: $event)';
}
