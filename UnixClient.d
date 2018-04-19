
import std.socket;
import SocketClient, StatusMessage, Command;

public class UnixClient : SocketClient
{
  private:
    Socket connectedSocket;
    string sockname;

  public:
    this(string socketname)
    {
      connectedSocket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
      connectTo = new UnixAddress(sockname);
    }
}

