import std.socket;
import ClientInterface, statusMessage, Command;


public abstract class SocketClient : ClientInterface
{
	protected:
		Socket connectedSocket;
		Address connectTo;

	public:
    void pushCommand(Command c)
    {
      Command cs[1];
      cs[0] = c;
      connectedSocket.send(cs);
    }

    StatusMessage getStatus()
    {
      //ubyte buf[5];
      StatusMessage ret[1];
      connectedSocket.receive(ret);
      //ret.p1h1 = buf[0];
      //ret.p1h2 = buf[1];
      //ret.p2h1 = buf[2];
      //ret.p2h2 = buf[3];
      //ret.turn = buf[4];
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
    ubyte initialize()
    {
      ubyte rec[1];
      connectedSocket.connect(connectTo);
      connectedSocket.receive(rec);
      return rec[0];
    }
}

