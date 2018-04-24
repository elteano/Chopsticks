import std.algorithm.iteration;
import std.socket;

import SocketClient, StatusMessage, Command;

public class InetClient : SocketClient
{
  private:
    string hostname;
    ushort port;

  protected:
    override Socket getSocket()
    {
      return new TcpSocket();
    }

    override Address getDestination()
    {
      return getAddress(hostname, port).filter!(a => a.addressFamily == AddressFamily.INET)().front;
    }

  public:
    this(string hostname, ushort port)
    {
      this.hostname = hostname;
      this.port = port;
    }
}
