import Player;

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
}

/**
 * Possible actions a player may take.
 *
 * Stored as a ubyte due to short list of possible values.
 */
enum CommandDirective : ubyte
{
  /// Hit one hand with another
  STRIKE,
  /// Split even value of our own hand
  SPLIT
}

