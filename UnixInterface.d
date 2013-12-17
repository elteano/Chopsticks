import std.stdio;
import std.socket;
import std.file;
import GameInterface, Command, StatusMessage, convenience;

/**
 * An implementation of the GameInterface that listens to UNIX sockets for a
 * client-server setup.
 */
public class UnixInterface : GameInterface
{

  private:
    Socket mSocket;
    Socket p1Socket;
    Socket p2Socket;
    string sockname;

  public:
    this(string socketname)
    {
      sockname = socketname;
      mSocket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
      if (exists(sockname))
      {
        writefln("Removing existing socket %s.", sockname);
        remove(sockname);
      }
      mSocket.bind(new UnixAddress(sockname));
    }

    //GameInterface functions
    Command getCommand()
    {
      Command c[1];
      mSocket.receive(c);
      return c[0];
    }

    Command getCommand(ubyte pnum)
    {
      Command c[1];
      switch(pnum % 2)
      {
        case 1:
          p2Socket.receive(c);
          break;
        case 0:
        default:
          p1Socket.receive(c);
        break;
      }
      return c[0];
    }

    /// Forwards the status to the two client connections
    void pushStatus(Player playerOne, Player playerTwo, ubyte turn)
    {
      writeln("Pushing status");
      StatusMessage mesg[1];
      mesg[0].p1h1 = playerOne.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p1h2 = playerOne.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].p2h1 = playerTwo.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p2h2 = playerTwo.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].turn = turn;
      //TODO check return values
      p1Socket.send(mesg);
      p2Socket.send(mesg);
      writeln("Done pushing status");
    }

    /// Listen for client connections.
    void initialize()
    {
      writeln("Waiting for players.");
      ubyte[] m1 = [0];
      ubyte[] m2 = [1];
      mSocket.listen(2);
      // Listen for the player one connection
      p1Socket = mSocket.accept();
      // Send a 0 character informing the recipient that they are the first
      // player
      p1Socket.send(m1);
      writeln("Player 0 connected.");
      // Listen for the player two connection
      p2Socket = mSocket.accept();
      // Send a 1 character informing the recipient that they are the second
      // player
      p2Socket.send(m2);
      writeln("Player 1 connected.");
    }

    version(NONE)
    {
      ~this()
      {
        // Shutdown and close the sockets
        p1Socket.shutdown(SocketShutdown.BOTH);
        p2Socket.shutdown(SocketShutdown.BOTH);
        mSocket.shutdown(SocketShutdown.BOTH);
        p1Socket.close();
        p2Socket.close();
        mSocket.close();

        // Clean up the old socket file descriptor
        remove(sockname);
      }
    }
}

