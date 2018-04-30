
/**
 * Struct representing a status message to be pushed out to the clients. It is
 * composed of five unsigned bytes representing hands one and two for player
 * one and two, followed by an unsigned byte representing the turn.
 */
public struct StatusMessage
{
  public:
    /// Player one, hand one
    ubyte p1h1;
    /// Player one, hand two
    ubyte p1h2;
    /// Player two, hand one
    ubyte p2h1;
    /// Player two, hand two
    ubyte p2h2;
    /// Turn value; even for p1, odd for p2
    ubyte turn;
}
