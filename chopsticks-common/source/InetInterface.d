import std.algorithm.iteration;
import std.socket;

import SocketGameInterface, convenience;

public class InetInterface : SocketGameInterface
{
	private:

	public:
		this(ushort portnum)
		{
			mSocket = new TcpSocket();
			mSocketAddr = getAddress("localhost", portnum).filter!(a => a.addressFamily == AddressFamily.INET).front;
		}
}
