module wtree;

import std.stdio;
import queue;
import std.container;

public class WTree(T)
{
  public:
    WTreeNode!T head;

    this(T headcontents)
    {
      head = new WTreeNode!T(headcontents);
      head.level = 0;
    }

    Queue!(WTreeNode!T) getLevelTraversalQueue()
    {
      auto ret = new Queue!(WTreeNode!T)();
      auto parse = new Queue!(WTreeNode!T)();
      ret.enqueue(head);
      parse.enqueue(head);
      while (!parse.empty())
      {
        auto node = parse.dequeue();
        foreach (n; node.children)
        {
          parse.enqueue(n);
          ret.enqueue(n);
        }
      }
      return ret;
    }
}

public class WTreeNode(T)
{
  public:
    WTreeNode!(T)[] children;
    WTreeNode!T parent;
    T contents;
    uint level;

    this(T contents)
    {
      this.contents = contents;
    }

    final WTreeNode!T generateNChild(T contents, uint childnum)
    {
      if (children.length <= childnum)
      {
        children.length = childnum+1;
      }
      children[childnum] = new WTreeNode!T(contents);
      children[childnum].level = level + 1;
      children[childnum].parent = this;
      return children[childnum];
    }

    final void printPathFromParent()
    {
      if (parent !is null)
      {
        parent.printPathFromParent();
        writef(" -> %s", contents);
      }
      else
      {
        writef("%s", contents);
      }
    }
}

