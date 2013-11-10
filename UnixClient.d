import std.socket;
import ClientInterface, StatusMessage, Command;

public class UnixClient : ClientInterface
{
  private:
  Socket connectedSocket;

  public:
  this(string socketname)
  {
  }

  void pushCommand(Command c)
  {
  }

  StatusMessage getStatus()
  {
    StatusMessage ret;
    connectedSocket.read(&StatusMessage);
    return ret;
  }

  void initialize()
  {
  }
}

