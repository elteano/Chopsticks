
module queue;

public class Queue(T)
{
  private:
    QueueNode!T front, back;

  public:
    this()
    {
    }

    final bool empty()
    {
      return front is null;
    }

    final void enqueue(T addition)
    {
      if (empty())
      {
        front = new QueueNode!T(addition);
        back = front;
      }
      else {
        back.back = new QueueNode!T(addition);
        back = back.back;
      }
    }

    final T dequeue()
    {
      auto ret = front.content;
      front = front.back;
      return ret;
    }
}

private class QueueNode(T)
{
  T content;
  QueueNode!T forward, back;

  this(T contents)
  {
    content = contents;
  }
}

