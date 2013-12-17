
import std.string;
import std.conv;
import std.stdio;
import std.regex;
import StatusMessage, ClientInterface, UnixClient, Command, convenience;

/**
 * User type that plays the game via a terminal.
 */
public class TerminalUser
{
  private:
    /// The method by which the user is connecting to the server.
    ClientInterface connection;
    /// Player number of this user.
    ubyte p_num;

    void gameLoop()
    {
      string input;
      StatusMessage currentStatus = connection.getStatus();
      printStatus(currentStatus);
      while((currentStatus.p1h1 != 0 || currentStatus.p1h2 != 0)
          && (currentStatus.p2h1 != 0 || currentStatus.p2h2 != 0))
      {
        if (currentStatus.turn == p_num)
        {
          input = readln();
          connection.pushCommand(parseCommand(chop(input)));
        }
        currentStatus=connection.getStatus();
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

    Command parseCommand(string command)
    {
      Command ret;
      writefln("entered %s", command);
      ret.player_src = p_num;
      if (command == "split")
      {
        ret.directive = CommandDirective.SPLIT;
      }
      else
      {
        ret.directive = CommandDirective.STRIKE;
        auto rx = regex("\\s+");
        auto split = split(command, rx);
        if (split[0] == "strike" && split.length >= 3)
        {
          ret.src_hand = cast(HandIdentifier) (parse!ubyte(split[1]) % 2);
          ret.tgt_hand = cast(HandIdentifier) (parse!ubyte(split[2]) % 2);
          writefln("src, tgt: %u, %u", ret.src_hand, ret.tgt_hand);
        }
        else{
          writefln("error: encountered %s", split[0]);
        }
      }
      return ret;
    }

  public:
    this()
    {
      writeln("Welcome to the number game!");
      connection = new UnixClient("asdf.sock");
    }
    void start()
    {
      writeln("Connecting to the server...");
      // Connect to the server and get the player number.
      p_num = connection.initialize();
      writefln("Connected! You are player number %u.", p_num);
      gameLoop();
    }
}

public void main(string[] args)
{
  auto termUser = new TerminalUser();
  termUser.start();
}

