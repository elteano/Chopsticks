
import Hand;
import convenience;

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

    this(ubyte startValue)
    {
      leftHand = new Hand(startValue);
      rightHand = new Hand(startValue);
    }

    /**
     * Splits the values of the hands.
     *
     * This function halves the value of one hand and sets the value of the
     * other hand to that value.
     *
     * Returns:
     * true if the split was successful; false if both hands were active.
     */
    bool splitHands()
    {
      if (leftHand.isActive() && rightHand.isActive())
        return false;
      if (leftHand.isActive())
      {
        rightHand.setNumber(leftHand.getNumber() / 2);
        leftHand.setNumber(leftHand.getNumber() / 2);
      }
      else
      {
        leftHand.setNumber(rightHand.getNumber() / 2);
        rightHand.setNumber(rightHand.getNumber() / 2);
      }
      return true;
    }

    /**
     * Tests whether the player is still alive.
     *
     * Alive is defined here as having at least one hand which is active (see
     * Hand.getActive()).
     *
     * Returns:
     * true if at least one hand is active; false otherwise.
     */
    bool isAlive()
    {
      return leftHand.isActive() || rightHand.isActive();
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

