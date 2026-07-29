/// SSE event type used by the backend to keep otherwise idle realtime streams
/// active across intermediaries.
const sseHeartbeatEventType = 'heartbeat';

/// One parsed Server-Sent Events frame.
class SseEvent {
  /// Creates an [SseEvent].
  const SseEvent({
    required this.data,
    this.type,
    this.id,
  });

  /// Optional event name declared by the backend.
  final String? type;

  /// Optional SSE event identifier.
  final String? id;

  /// Decoded JSON payload carried by the `data:` lines.
  final Map<String, dynamic> data;
}

/// Returns whether [event] is a transport heartbeat that feature consumers
/// should ignore.
bool isHeartbeatSseEvent(SseEvent event) => event.type == sseHeartbeatEventType;
