import std.concurrency;
import std.stdio;

import Command;
import GameInterface;
import InetInterface;
import Player;
import StatusPrefix: StatusPrefix;
import UnixInterface;

/**
 * Enum type containing errors which may occur while interpreting a command.
 */
private enum CommandError : ubyte
{
  /// No error occurred.
  NONE = 0,
  /// The command was received out of turn.
  OUT_OF_TURN,
  /// The strike coma
  MALFORMED_STRIKE,
  /// Striking to or from an inactive hand
  ILLEGAL_STRIKE,
  /// Player trying to split when they already have two active hands.
  IMPROPER_SPLIT
}

/**
 * Server for hosting the game. The idea is that this class will be somewhat
 * extensible to allow for multiple methods of playing the game.
 */
public class GameServer
{
  private:
    GameInterface clientInterface;
    Player player1;
    Player player2;
    ubyte turn;

    /**
     * Advances to the next turn. This is necessary to maintin implementation
     * agnostic in the unlikely event that turns be stored differently in the
     * future.
     */
    void nextTurn()
    {
      ++turn;
      turn %= 2;
    }

    /**
     * The main game loop. Calls functions as necessary to maintain the game
     * flow.
     */
    void gameLoop()
    {
      while (player1.isAlive() && player2.isAlive())
      {
        CommandError err;
        writefln("Turn %d.", turn);
        // Tell everyone how it is
        clientInterface.pushStatus(player1, player2, turn);

        // Get told how it is
        auto msg = receiveOnly!(ubyte, Command);
        ubyte pNum = msg[0];
        Command c = msg[1];
        writeln("Received command.");
        switch (c.prefix)
        {
          case StatusPrefix.STATUS_POLL:
            clientInterface.pushStatus(pNum, player1, player2, turn);
            break;
          case StatusPrefix.PLAY_INCOMING:
            if ((err = interpretCommand(pNum, c)) == CommandError.NONE)
            {
              nextTurn();
            }
            else
            {
              switch(err)
              {
                case CommandError.OUT_OF_TURN:
                  writefln("Received from %u, expected %u.", pNum, turn);
                  break;
                case CommandError.ILLEGAL_STRIKE:
                  writefln("Player %u attempted an illegal strike.", pNum);
                  break;
                default:
                  writefln("error: %u", err);
                  break;
              }
            }
            break;
          // If there's an error, then we always gotta get a resend
          default:
            //ignore
            break;
        }
      }
      clientInterface.pushStatus(player1, player2, turn);
    }

    /**
     * Interprets a command and acts upon it.
     *
     * This function fails if the passed command is illegal. It always returns
     * a type of CommandError, which is documented elsewhere. The value
     * returned corresponds to the error (or lack thereof) which ocurred during
     * execution.
     *
     * Returns:
     * See CommandError.
     */
    CommandError interpretCommand(ubyte pNum, in Command c)
    {
      if ((turn % 2) == pNum)
      {
        Player src, dest;
        switch(pNum)
        {
          case 0:
            src = player1;
            dest = player2;
            break;
          case 1:
            src = player2;
            dest = player1;
            break;
          default:
            // Default to player one hitting player two.
            src = player1;
            dest = player2;
            break;
        }
        final switch(c.directive)
        {
          case CommandDirective.STRIKE:
            if (dest.getHand(c.tgt_hand).isActive() && src.getHand(c.src_hand).isActive())
            {
              dest.getHand(c.tgt_hand).increment(src.getHand(c.src_hand)
                                                 .getNumber());
            }
            else
            {
              return CommandError.ILLEGAL_STRIKE;
            }
            break;
          case CommandDirective.SPLIT:
            if (!src.splitHands())
            {
              return CommandError.IMPROPER_SPLIT;
            }
            break;
        }
      }
      else {
        return CommandError.OUT_OF_TURN;
      }
      // No error returned - report success!
      return CommandError.NONE;
    }

    void handleMessage(ubyte pNum)
    {

    }

  public:
    this()
    {
      // Create everything
      player1 = new Player(1);
      player2 = new Player(1);
      clientInterface = new InetInterface(cast(ushort) 31718);
    }

    void start()
    {
      // Wait for clients
      clientInterface.initialize();

      // Do game stuff
      gameLoop();
    }
}

public void main(char[][] args)
{
  GameServer gs = new GameServer();
  gs.start();
}
