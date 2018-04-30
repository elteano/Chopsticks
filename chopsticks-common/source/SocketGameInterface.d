import std.concurrency;
import std.stdio;
import std.socket;
import std.file;

import convenience;
import Command;
import GameInterface;
import Player;
import StatusMessage;
import StatusPrefix: StatusPrefix;
import SocketShare: SocketShare;

/**
 * An interface type designed to make working with various sockets easier. The
 * game was originally set up to use Unix sockets, and this was created to allow
 * that code to also work for Inet sockets.
 */
public abstract class SocketGameInterface : GameInterface
{
  protected:
    Socket mSocket;
    shared SocketShare p1Socket;
    shared SocketShare p2Socket;
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
      switch (pnum % 2)
      {
        case 1:
          p2Socket.syncReceive(c);
          break;
        case 0:
        default:
          p1Socket.syncReceive(c);
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
      p1Socket = new shared SocketShare(mSocket.accept());
      // Send a 0 character informing the recipient that they are the first
      // player
      p1Socket.syncSend(m1);
      writeln("Player 0 connected.");
      // Listen for the player two connection
      p2Socket = new shared SocketShare(mSocket.accept());
      // Send a 1 character informing the recipient that they are the second
      // player
      p2Socket.syncSend(m2);
      writeln("Player 1 connected.");

      spawn(&listenLoop, cast(ubyte) 0, p1Socket);
      spawn(&listenLoop, cast(ubyte) 1, p2Socket);
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
      p1Socket.syncSend(mesg);
      p2Socket.syncSend(mesg);
      writeln("Done pushing status");
    }

    void pushStatus(ubyte dest, Player playerOne, Player playerTwo, ubyte turn)
    {
      writefln("Pushing status to player %d", dest + 1);
      StatusMessage[1] mesg;
      mesg[0].p1h1 = playerOne.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p1h2 = playerOne.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].p2h1 = playerTwo.getHand(HandIdentifier.LEFT).getNumber();
      mesg[0].p2h2 = playerTwo.getHand(HandIdentifier.RIGHT).getNumber();
      mesg[0].turn = turn;
      //TODO check return values
      if (dest == 0)
      {
        p1Socket.syncSend(mesg);
      }
      else if (dest == 1)
      {
        p2Socket.syncSend(mesg);
      }
      else{
        writefln("Illegal status destination %d.", dest);
      }
      writeln("Done pushing status");
    }
}

void syncSend(shared Socket sock, const(void)[] buf)
{
  synchronized (sock)
  {
    writeln("Send sync start");
    auto unwrap = cast(Socket) sock;
    unwrap.send(buf);
    writeln("Send sync end");
  }
}

auto syncReceive(shared Socket sock, void[] buf)
{
  synchronized (sock)
  {
    writeln("Receive sync start");
    auto unwrap = cast(Socket) sock;
    auto l = unwrap.receive(buf);
    writeln("Receive sync end");
    return l;
  }
}

void listenLoop(ubyte pNum, shared SocketShare sock)
{
  // sock.receive() will return 0 when the other side is closed
  writefln("Loop started for %d.", pNum);
  long n = 0;
  Command[1] command;
  n = sock.syncReceive(command);
  writefln("Received for %d.", pNum);
  while (n != 0)
  {
    ownerTid().send(pNum, command[0]);
    n = sock.syncReceive(command);
  }
}
