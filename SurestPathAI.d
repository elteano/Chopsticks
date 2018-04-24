
import std.stdio;
import StatusMessage;
import UnixClient;
import treemaker;
import convenience;
import wtree;
import Command;
import ClientInterface;

public class SurestPathAi
{
  private:
    ClientInterface connection;
    ubyte p_num;

    void gameLoop()
    {
      StatusMessage currentStatus = connection.getStatus();
      printStatus(currentStatus);
      while((currentStatus.p1h1 != 0 || currentStatus.p1h2 != 0)
          && (currentStatus.p2h1 != 0 || currentStatus.p2h2 != 0))
      {
        if (currentStatus.turn == p_num)
        {
          // TODO Ensure the current path is correct
          TurnInstance currentTurn;
          currentTurn.left.left = currentStatus.p1h1;
          currentTurn.left.right = currentStatus.p1h2;
          currentTurn.right.left = currentStatus.p2h1;
          currentTurn.right.right = currentStatus.p2h2;
          connection.pushCommand(getNextCommand(currentTurn));
        }
        currentStatus=connection.getStatus();
        printStatus(currentStatus);
      }
      ubyte winner = 0;
      if (currentStatus.p1h1 == 0 && currentStatus.p1h2 == 0)
      {
        winner = 1;
      }
      if (winner == p_num)
      {
        writefln("This Surest Path AI wins!");
      }
      else
      {
        writefln("This Surest Path AI lost!");
      }
    }

    Command getNextCommand(TurnInstance currentTurn)
    {
      Command ret;
      // Assume that we've deviated from the path
      auto destination = getSurestPath(currentTurn, 12, p_num);
      getCommandFromTree(ret, currentTurn, destination);
      writefln("%s", ret);
      return ret;
    }

    bool getCommandFromTree(out Command output, TurnInstance currentTurn,
        WTreeNode!TurnValue destination)
    {
      WTreeNode!TurnValue next;
      real maxNext = -real.max;
      // Choose left or right by the numbers
      foreach (child ; destination.children)
      {
        if (child !is null && child.contents.right > maxNext)
        {
          maxNext = child.contents.right;
          next = child;
        }
      }
      output = findDifference(currentTurn, next.contents.left);
      return true;
    }

    Command findDifference(TurnInstance start, TurnInstance next)
    {
      // If this is false, then right side differs
      bool left_differs = false;
      writefln("Going from %s to %s.", start, next);
      // Check which side differs
      if (start.left != next.left)
      {
        writeln("Left differs.");
        left_differs = true;
      }
      switch (p_num)
      {
        case 0: // Use left side for current player
          if (left_differs)
          {
            // This player differs, so split
            return Command.Command(p_num, CommandDirective.SPLIT,
                HandIdentifier.LEFT, HandIdentifier.LEFT);
          }
          else {
            // Opposing player differs, so make appropriate strike
            // Determine which command hit what
            return getStep(p_num, start.left, start.right, next.right);
          }
        default: // Use right side for current player
          if (left_differs)
          {
            writeln("Because left differs, striking foe.");
            // Opposing player differs, so make appropriate strike
            return getStep(p_num, start.right, start.left, next.left);
          }
          else {
            // This player differs, so split
            return Command.Command(p_num, CommandDirective.SPLIT,
                HandIdentifier.LEFT, HandIdentifier.LEFT);
          }
      }
    }

    private void printStatus(StatusMessage status)
    {
      ubyte h1, h2, eh1, eh2;
      switch(p_num)
      {
        case 1:
          h1 = status.p2h1;
          h2 = status.p2h2;
          eh1 = status.p1h1;
          eh2 = status.p1h2;
          break;
        case 0:
        default:
          h1 = status.p1h1;
          h2 = status.p1h2;
          eh1 = status.p2h1;
          eh2 = status.p2h2;
          break;
      }
      if (status.turn == p_num)
      {
        writeln("It is your turn.");
      }
      else
      {
        writeln("It is the opponent's turn.");
      }
      writefln("Your hands have %u and %u. Your foe has %u and %u.", h1, h2,
          eh1, eh2);
    }

  public:
    void start()
    {
      connection = new UnixClient("asdf.sock");
      p_num = connection.initialize();
      gameLoop();
    }
}

private Command getStep(uint p_num, Hand ours, Hand theirFirst,
    Hand theirSecond)
{
  // What to return
  Command ret;
  // The difference between their first and second hands
  Hand diff;
  // True if their left hand changed, false if right
  bool leftChanged = false;
  // The amount by which one of their hands changed
  int hdiff;
  // First, get the difference between their hands
  diff.left = theirSecond.left - theirFirst.left;
  diff.right = theirSecond.right - theirFirst.right;
  // Now determine which side changed
  leftChanged = diff.left != 0;
  // Get the amount by which their hand changed
  hdiff = (leftChanged) ? diff.left : diff.right;
  // Normalize hdiff to a number that would appear on our hand
  if (hdiff < 0)
  {
    hdiff += 5;
  }
  // Determine which of our hands corresponds to this difference
  if (ours.left == hdiff)
  {
    ret.src_hand = HandIdentifier.LEFT;
  }
  else {
    ret.src_hand = HandIdentifier.RIGHT;
  }
  // Fill in the rest of the return
  ret.player_src = p_num;
  ret.directive = CommandDirective.STRIKE;
  ret.tgt_hand = (leftChanged) ? HandIdentifier.LEFT
    : HandIdentifier.RIGHT;
  return ret;
}

public void main(string[] args)
{
  auto ai = new SurestPathAi();
  ai.start();
}

