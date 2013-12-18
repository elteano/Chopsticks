
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

// Misnamed pair representing the hands of a player
public alias Pair!(int, int) Hand;
// Pair representing both players in a given turn
public alias Pair!(Hand, Hand) TurnInstance;
// Pairing of a turn and the likelihood that the AI will win from this turn
public alias Pair!(TurnInstance, real) TurnValue;

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
  // Create a new tree with the start as its head
  auto tree = new WTree!TurnInstance(start);
  // Create a queue for level-order traversal and population of the tree
  auto queue = new Queue!(WTreeNode!TurnInstance)();
  // Enqueue the root node to enable traveral
  queue.enqueue(tree.head);
  while (!queue.empty() && checksMade < depth)
  {
    auto node = queue.dequeue();
    checksMade = node.level;
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

/***
 * Builds a tree lining out the surest path to victory from the starting point.
 * Params:
 *  start - the turn value representing where to begin
 *  depth - how far down to search
 *  p_num - 0 for first player, 1 for second
 * Return:
 *  The root node of the tree, populated with appropriate values.
 */
public WTreeNode!TurnValue getSurestPath(TurnInstance start, uint depth, ubyte p_num)
{
  uint checksMade = 0;
  // Root node of the tree; will be returned.
  auto tree = new WTree!TurnValue(TurnValue(start, 0));
  // Queue for level-order traversal and population of the tree
  auto queue = new Queue!(WTreeNode!TurnValue)();
  // Enqueue the head so that we have something to traverse later
  queue.enqueue(tree.head);
  // Begin traversing the queue
  while (!queue.empty() && checksMade < depth)
  {
    // Pull out the next node on the queue
    auto node = queue.dequeue();
    auto turn = node.contents.left;
    // Get the depth of the node
    checksMade = node.level;
    // If this node contains a death, act appropriately
    if (turn.left.left == 0 && turn.left.right == 0
      || turn.right.left == 0 && turn.right.right == 0)
    {
      // Go up to the root, incrementing or decrementing the value
      real modifier = (turn.left.left == 0 && p_num == 1) ? -1 : 1;
      auto traversal = node;
      while (traversal.parent !is null)
      {
        traversal.contents.right += modifier;
        modifier *= cast(real) 3/4;
        traversal = traversal.parent;
      }
      // Continue so that we don't populate anything below this node
      continue;
    }
    // Possible branches from the current node
    TurnInstance ll, lr, rl, rr, split;
    // booleans representing whether the branches are valid
    bool llGood, lrGood, rlGood, rrGood, splitGood;
    // Populate branches and check validity based on current turn
    switch((node.level + p_num) % 2)
    {
      case 0:
        // Player 0 turn
        llGood = turn.left.left != 0 && turn.right.left != 0;
        rlGood = turn.left.right != 0 && turn.right.left != 0;
        lrGood = turn.left.left != 0 && turn.right.right != 0;
        rrGood = turn.left.right != 0 && turn.right.right != 0;
        splitGood = turn.left.left == 0
          && turn.left.right % 2 == 0 || turn.left.right == 0
          && turn.left.left % 2 == 0;
        ll = TurnInstance(turn.left, combineLL(turn.left, turn.right));
        lr = TurnInstance(turn.left, combineLR(turn.left, turn.right));
        rl = TurnInstance(turn.left, combineRL(turn.left, turn.right));
        rr = TurnInstance(turn.left, combineRR(turn.left, turn.right));
        split = TurnInstance(calculateSplit(turn.left), turn.right);
        break;
      default:
        // Player 1 turn
        llGood = turn.right.left != 0 && turn.left.left != 0;
        rlGood = turn.right.right != 0 && turn.left.left != 0;
        lrGood = turn.right.left != 0 && turn.left.right != 0;
        rrGood = turn.right.right != 0 && turn.left.right != 0;
        splitGood = turn.right.left == 0
          && turn.right.right % 2 == 0
          || turn.right.right == 0 && turn.right.left % 2 == 0;
        ll = TurnInstance(combineLL(turn.right, turn.left), turn.right);
        lr = TurnInstance(combineLR(turn.right, turn.left), turn.right);
        rl = TurnInstance(combineRL(turn.right, turn.left), turn.right);
        rr = TurnInstance(combineRR(turn.right, turn.left), turn.right);
        split = TurnInstance(turn.left, calculateSplit(turn.right));
        break;
    }
    // Enqueue valid branches and add them to the tree
    if (llGood)
    queue.enqueue(node.generateNChild(TurnValue(ll, 0), 0));
    if (lrGood && lr != ll)
      queue.enqueue(node.generateNChild(TurnValue(lr, 0), 1));
    if (rlGood && rl != ll && rl != lr)
      queue.enqueue(node.generateNChild(TurnValue(rl, 0), 2));
    if (rrGood && rr != ll && rr != lr && rr != rl)
      queue.enqueue(node.generateNChild(TurnValue(rr, 0), 3));
    if(splitGood)
      queue.enqueue(node.generateNChild(TurnValue(split, 0), 4));
  }
  // Return the root node of the tree
  return tree.head;
}

