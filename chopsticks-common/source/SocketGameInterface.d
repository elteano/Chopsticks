import std.stdio;
import std.socket;
import std.file;
import GameInterface, Command, StatusMessage, Player, convenience;

public abstract class SocketGameInterface : GameInterface
{
	protected:
    Socket mSocket;
    Socket p1Socket;
    Socket p2Socket;
		Address mSocketAddr;

	public:
    //GameInterface functions
    Command getCommand()
    {
      Command[1] c;
      mSocket.receive(c);
      return c[0];
    }

    Command getCommand(ubyte pnum)
    {
      Command[1] c;
      switch(pnum % 2)
      {
        case 1:
          p2Socket.receive(c);
          break;
        case 0:
        default:
          p1Socket.receive(c);
        break;
      }
      return c[0];
    }

    /// Listen for client connections.
    void initialize()
    {
      stderr.writefln("Listening to address %s", mSocketAddr);
      stderr.flush();
      mSocket.bind(mSocketAddr);

      writeln("Waiting for players.");
      ubyte[] m1 = [0];
      ubyte[] m2 = [1];
      mSocket.listen(2);
      // Listen for the player one connection
      p1Socket = mSocket.accept();
      // Send a 0 character informing the recipient that they are the first
      // player
      p1Socket.send(m1);
      writeln("Player 0 connected.");
      // Listen for the player two connection
      p2Socket = mSocket.accept();
      // Send a 1 character informing the recipient that they are the second
      // player
      p2Socket.send(m2);
      writeln("Player 1 connected.");
    }

    /// Forwards the status to the two client connections
    void pushStatus(Player playerOne, Player playerTwo, ubyte turn)
    {
      writeln("Pushing status");
      StatusMessage[1] mesg;
      mesg[0].p1h1 = playerOne.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p1h2 = playerOne.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].p2h1 = playerTwo.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p2h2 = playerTwo.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].turn = turn;
      //TODO check return values
      p1Socket.send(mesg);
      p2Socket.send(mesg);
      writeln("Done pushing status");
    }
}
