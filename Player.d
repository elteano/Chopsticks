import Hand;

public static enum HandIdentifier : ubyte { LEFT, RIGHT }

/**
 * Class representing a player in the number game. The player has two hands;
 * other than that, the class is in charge of very little.
 */
public class Player
{
  private:
  Hand leftHand, rightHand;

  public:

  this()
  {
    this(1);
  }

  this(uint startValue)
  {
    leftHand = new Hand(startValue);
    rightHand = new Hand(startValue);
  }

  Hand getLeftHand()
  {
    return leftHand;
  }

  Hand getRightHand()
  {
    return rightHand;
  }

  /**
   * Returns the hand given by the enum HandIdentifier value. This is the
   * preferred method of retrieving hands.
   */
  Hand getHand(HandIdentifier ident)
  {
    final switch(ident)
    {
      case HandIdentifier.LEFT:
        return getLeftHand();
      case HandIdentifier.RIGHT:
        return getRightHand();
    }
  }
}
