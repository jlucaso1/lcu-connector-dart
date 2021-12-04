class EventResponse<T> {
  final String uri;
  final T data;
  final String eventType;

  EventResponse(
      {required this.uri, required this.data, required this.eventType});

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      uri: json["uri"],
      data: json["data"],
      eventType: json["eventType"],
    );
  }
}
