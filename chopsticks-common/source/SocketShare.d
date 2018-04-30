import core.sync.mutex;

import std.socket;

class SocketShare
{
  private:
    shared Mutex readMtx;
    shared Mutex writeMtx;
    shared Socket sock;

  public:
    this(Socket sock)shared
    {
      this.sock = cast(shared Socket) sock;
      readMtx = new shared Mutex();
      writeMtx = new shared Mutex();
    }

    auto receive(void[] buf) shared
    {
      readMtx.lock();
      auto s = cast(Socket) sock;
      auto r = s.receive(buf);
      readMtx.unlock();
      return r;
    }

    auto send(const(void)[] buf) shared
    {
      writeMtx.lock();
      auto s = cast(Socket) sock;
      s.send(buf);
      writeMtx.unlock();
    }

    alias syncSend = send;
    alias syncReceive = receive;
}
