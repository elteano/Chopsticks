import std.socket;
import GameInterface, Command, StatusMessage;

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

  public:
    this(string socketname)
    {
      mSocket = new Socket(UNIX, STREAM);
      mSocket.bind(new UnixAddress(socketname));
    }

    //GameInterface functions
    Command getCommand()
    {
    }

    /// Forwards the status to the two client connections
    void pushStatus(Player p1, Player p2, uint turn)
    {
    }

    /// Listen for client connections.
    void intialize()
    {
      // Listen for the player one connection
      p1Socket = mSocket.accept();
      // Send a 0 character informing the recipient that they are the first
      // player
      p1Socket.send("0");
      // Listen for the player two connection
      p2Socket = mSocket.accept();
      // Send a 1 character informing the recipient that they are the second
      // player
      p2Socket.send("1");
    }
}

