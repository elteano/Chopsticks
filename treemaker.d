
module treemaker;

import std.stdio;
import std.container;
import std.conv;
import wtree;
import queue;

public struct Pair(A, B)
{
  public:
    A left;
    B right;

    string toString()
    {
      return "(" ~ to!string(left) ~ ", " ~ to!string(right) ~ ")";
    }
  
    /*
    bool opEquals(Object o)
    {
      auto cmp = cast(Pair!(A, B)) o;
      return cmp && left == cmp.left && right == cmp.right;
    }
    */
}

public alias Pair!(int, int) Hand;
public alias Pair!(Hand, Hand) TurnInstance;

private enum ubyte MAX_CHECK_DEPTH = 12;

public Hand combineRL(Hand src, Hand tgt)
{
  return Hand((tgt.left + src.right) % 5, tgt.right);
}

public Hand combineRR(Hand src, Hand tgt)
{
  return Hand(tgt.left, (tgt.right + src.right) % 5);
}

public Hand combineLL(Hand src, Hand tgt)
{
  return Hand((tgt.left + src.left) % 5, tgt.right);
}

public Hand combineLR(Hand src, Hand tgt)
{
  return Hand(tgt.left, (tgt.right + src.left) % 5);
}

public Hand calculateSplit(Hand src)
{
  Hand ret;
  // Determine which hand is the source of the split
  if (src.left == 0)
  {
    // Split from the right
    ret.left = src.right / 2;
    ret.right = ret.left;
  }
  else {
    // Split from the left
    ret.right = src.left / 2;
    ret.left = ret.right;
  }
  return ret;
}

public WTreeNode!TurnInstance getShortestPath(TurnInstance start, uint depth, ubyte p_num)
{
  uint checksMade = 0;
  auto tree = new WTree!TurnInstance(start);
  //tree.head.left = new BTreeNode!Hand(Hand(2, 2));
  //tree.head.right = new BTreeNode!Hand(Hand(3, 7));
  //auto queue = tree.getLevelTraversalQueue();
  auto queue = new Queue!(WTreeNode!TurnInstance)();
  queue.enqueue(tree.head);
  while (!queue.empty() && checksMade < depth)
  {
    auto node = queue.dequeue();
    checksMade = node.level;
    // Print out the node
    //writefln("(%d %d), (%d %d)", node.contents.left.left,
    //    node.contents.left.right, node.contents.right.left,
    //    node.contents.right.right);
    // Report a death
    if (node.contents.left.left == 0 && node.contents.left.right == 0 && p_num == 1
      || node.contents.right.left == 0 && node.contents.right.right == 0 && p_num == 0)
    {
      //writefln("Death %d levels in!", node.level);
      // Reveal steps to death
      //node.printPathFromParent();
      //writeln();
      // return the dead node
      return node;
      continue;
    }
    TurnInstance ll, lr, rl, rr, split;
    bool llGood, lrGood, rlGood, rrGood, splitGood;
    switch((node.level + p_num) % 2)
    {
      case 0:
        // Player 0 turn
        llGood = node.contents.left.left != 0 && node.contents.right.left != 0;
        rlGood = node.contents.left.right != 0 && node.contents.right.left != 0;
        lrGood = node.contents.left.left != 0 && node.contents.right.right != 0;
        rrGood = node.contents.left.right != 0 && node.contents.right.right != 0;
        splitGood = node.contents.left.left == 0
          && node.contents.left.right % 2 == 0 || node.contents.left.right == 0
          && node.contents.left.left % 2 == 0;
        ll = TurnInstance(node.contents.left, combineLL(node.contents.left, node.contents.right));
        lr = TurnInstance(node.contents.left, combineLR(node.contents.left, node.contents.right));
        rl = TurnInstance(node.contents.left, combineRL(node.contents.left, node.contents.right));
        rr = TurnInstance(node.contents.left, combineRR(node.contents.left, node.contents.right));
        split = TurnInstance(calculateSplit(node.contents.left), node.contents.right);
        break;
      default:
        // Player 1 turn
        llGood = node.contents.right.left != 0 && node.contents.left.left != 0;
        rlGood = node.contents.right.right != 0 && node.contents.left.left != 0;
        lrGood = node.contents.right.left != 0 && node.contents.left.right != 0;
        rrGood = node.contents.right.right != 0 && node.contents.left.right != 0;
        splitGood = node.contents.right.left == 0
          && node.contents.right.right % 2 == 0
          || node.contents.right.right == 0 && node.contents.right.left % 2 == 0;
        ll = TurnInstance(combineLL(node.contents.right, node.contents.left), node.contents.right);
        lr = TurnInstance(combineLR(node.contents.right, node.contents.left), node.contents.right);
        rl = TurnInstance(combineRL(node.contents.right, node.contents.left), node.contents.right);
        rr = TurnInstance(combineRR(node.contents.right, node.contents.left), node.contents.right);
        split = TurnInstance(node.contents.left, calculateSplit(node.contents.right));
        break;
    }
    if (llGood)
    queue.enqueue(node.generateNChild(ll, 0));
    if (lrGood && lr != ll)
      queue.enqueue(node.generateNChild(lr, 1));
    if (rlGood && rl != ll && rl != lr)
      queue.enqueue(node.generateNChild(rl, 2));
    if (rrGood && rr != ll && rr != lr && rr != rl)
      queue.enqueue(node.generateNChild(rr, 3));
    if(splitGood)
      queue.enqueue(node.generateNChild(split, 4));
  }
  writeln("That's all.");
  return null;
}

