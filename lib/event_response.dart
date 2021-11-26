class EventResponse<T> {
  late String uri;
  late T data;
  late String eventType;
  EventResponse.fromJson(Map<String, dynamic> json) {
    uri = json["uri"];
    data = json["data"];
    eventType = json["eventType"];
  }
}
