import std.stdio;
import std.socket;
import std.file;
import SocketGameInterface, Command, StatusMessage, convenience;

/**
 * An implementation of the GameInterface that listens to UNIX sockets for a
 * client-server setup.
 */
public class UnixInterface : SocketGameInterface
{

  private:
    string sockname;

  public:
    this(string socketname)
    {
			version(Posix)
			{
				sockname = socketname;
				mSocket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
				if (exists(sockname))
				{
					writefln("Removing existing socket %s.", sockname);
					remove(sockname);
				}
				mSocketAddr = new UnixAddress(sockname);
			}
			else
			{
				throw new Exception("Unix ports are unsupported outside of POSIX systems.");
			}
    }
}

