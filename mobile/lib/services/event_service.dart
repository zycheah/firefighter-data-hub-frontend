import '../models/event_model.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  Event? _lastEvent;

  Event? getLastEvent() => _lastEvent;

  Future<void> saveEvent(Event event) async {
    _lastEvent = event;
  }
}
