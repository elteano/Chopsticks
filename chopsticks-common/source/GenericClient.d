import std.stdio;

import ClientDecider;
import ClientInterface;
import StatusMessage;

/**
 * This is a generic client which uses a ClientInterface and ClientDecider
 * provided to it by a third party. It is intended to make client design
 * easier.
 *
 * Largely based off code stolen from ShortestPathAi.
 */
public class GenericClient
{
  private:
    ClientDecider decider;
    ClientInterface connection;
    ubyte p_num;

    void printStatus(StatusMessage status)
    {
      ubyte h1, h2, eh1, eh2;
      switch(p_num)
      {
        case 1:
          h1 = status.p2h1;
          h2 = status.p2h2;
          eh1 = status.p1h1;
          eh2 = status.p1h2;
          break;
        case 0:
        default:
          h1 = status.p1h1;
          h2 = status.p1h2;
          eh1 = status.p2h1;
          eh2 = status.p2h2;
          break;
      }
      if (status.turn == p_num)
      {
        writeln("It is your turn.");
      }
      else
      {
        writeln("It is the opponent's turn.");
      }
      writefln("Your hands have %u and %u. Your foe has %u and %u.", h1, h2,
          eh1, eh2);
    }

  public:
    this(ClientDecider decider, ClientInterface connection)
    {
      this.decider = decider;
      this.connection = connection;
    }

    void gameLoop()
    {
      StatusMessage currentStatus = connection.getStatus();
      printStatus(currentStatus);
      // 5 because it is neither 0 nor 1
      ubyte prev_poll = 5;
      while((currentStatus.p1h1 != 0 || currentStatus.p1h2 != 0)
          && (currentStatus.p2h1 != 0 || currentStatus.p2h2 != 0))
      {
        if (currentStatus.turn == p_num)
        {
          connection.pushCommand(decider.getNextPlay(p_num, currentStatus));
        }
        currentStatus = connection.getStatus();
        printStatus(currentStatus);
      }
      ubyte winner = 0;
      if (currentStatus.p1h1 == 0 && currentStatus.p1h2 == 0)
      {
        winner = 1;
      }
      if (winner == p_num)
      {
        writefln("You win!");
      }
      else
      {
        writefln("You lose!");
      }
    }
}

