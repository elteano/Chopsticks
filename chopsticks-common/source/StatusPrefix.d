/**
 * A single byte which can be used to tell someone what kind of message they're
 * about to receive, or just give a short update message if that's all they
 * need.
 */
enum StatusPrefix : ubyte
{
  /// Server -> Client. Server is telling the client what's what
  STATUS_INCOMING,
  /// Client -> Server. Client is making a move
  PLAY_INCOMING,
  /// Client -> Server. Client wants an update on the game status
  STATUS_POLL,
  /// Server -> Client. The client wins!
  YOU_LOSE,
  /// Server -> Client. The client has lost.
  YOU_WIN
}
