
import std.socket;
import SocketClient, StatusMessage, Command;

public class UnixClient : SocketClient
{
  private:
    string sockname;

  protected:
    override Socket getSocket()
    {
      return new Socket(AddressFamily.UNIX, SocketType.STREAM);
    }

    override Address getDestination()
    {
      version(Posix)
      {
        return new UnixAddress(sockname);
      }
      else
      {
        throw new Exception("Unix ports are unsupported outside of POSIX systems.");
      }
    }

  public:
    this(string socketname)
    {
      version(Posix) {}
      else
      {
        throw new Exception("Unix ports are unsupported outside of POSIX systems.");
      }
    }
}

