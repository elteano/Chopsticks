import Player;
import convenience;
import std.conv;

/**
 * Describes data fields for passing commands around. This is the primary means
 * of communication between GameInterfaces and the GameServer.
 */
public struct Command
{
  public:
    /// Player initiating the command
    uint player_src;
    /// Action to be taken by the player.
    CommandDirective directive;
    /// Hand used by the player; unused if directive is SPLIT
    HandIdentifier src_hand;
    /// Hand targeted by the player; unused if directive is SPLIT
    HandIdentifier tgt_hand;

    this(uint p_src, CommandDirective dir, HandIdentifier src,
        HandIdentifier tgt)
    {
      player_src = p_src;
      directive = dir;
      src_hand = src;
      tgt_hand = tgt;
    }

    string toString()
    {
      final switch (directive)
      {
        case CommandDirective.STRIKE:
          return to!string(player_src) ~ ": STRIKE " ~ to!string(src_hand)
            ~ " -> " ~ to!string(tgt_hand);
        case CommandDirective.SPLIT:
          return to!string(player_src) ~ ": SPLIT";
      }
    }
}

/**
 * Possible actions a player may take.
 *
 * Stored as a ubyte due to short list of possible values.
 */
public enum CommandDirective : ubyte
{
  /// Hit one hand with another
  STRIKE,
  /// Split even value of our own hand
  SPLIT
}

