import std.socket;

import SocketInterface, StatusMessage, Command;

public class InetClient : SocketClient
{
	private:
		Socket connectedSocket;
		string sockname;

	public:
		this(string hostname, ushort port)
		{
			connectedSocket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
			connectTo = getAddress(hostname, 71718);
		}
}
