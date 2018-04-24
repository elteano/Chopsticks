import std.socket;
import std.stdio;

import ClientInterface, StatusMessage, Command;

public abstract class SocketClient : ClientInterface
{
  private:
    Socket connectedSocket;
    Address connectTo;

  protected:
    abstract Socket getSocket();
    abstract Address getDestination();

  public:
    void pushCommand(Command c)
    {
      Command[1] cs;
      cs[0] = c;
      connectedSocket.send(cs);
    }

    StatusMessage getStatus()
    {
      StatusMessage[1] ret;
      connectedSocket.receive(ret);
      return ret[0];
    }

    /**
     * Initializes the connection.
     *
     * This will connect to the socket at the address given during
     * initialization. It will block execution until the connection is
     * established.
     *
     * Returns:
     * The player number; 0 for player 1, 1 for player 2.
     */
  override final ubyte initialize()
  {
    connectedSocket = getSocket();
    connectTo = getDestination();

    ubyte[1] rec;
    writefln("Connecting to: %s", connectTo);
    stdout.flush();
    connectedSocket.connect(connectTo);
    connectedSocket.receive(rec);
    return rec[0];
  }
}

