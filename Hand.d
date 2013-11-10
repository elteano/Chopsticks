/**
 * The maximum number of fingers allowed up at a time. If this number is
 * reached, then the number of active fingers resets to zero.
 */
private immutable MAX_NUMBER = 5;

/**
 * Represents one "hand" from the original game, storing the number of
 * "fingers" which are up on that hand.
 */
public class Hand
{
  /**
   * The number of "fingers" up on the hand.
   */
  private uint number;

  public:

  /**
   * Creates a hand with the default starting value of one.
   */
  this()
  {
    this(1);
  }

  /**
   * Creates a hand with the given starting value.
   */
  this(uint startValue)
  {
    number = startValue;
  }

  /**
   * Adds the given number to the number of fingers currently on the hand.
   * Restores the hand to a real value of fingers (between 0 and 5).
   */
  void increment(uint value)
  {
    number += value;
    number %= MAX_NUMBER;
  }

  /**
   * Gets the number of "fingers" up on the hand.
   */
  uint getNumber()
  {
    return number;
  }

  /**
   * Returns true if the hand is available for use. Specifically, this returns
   * true if there are zero fingers active on a hand.
   */
  bool isActive()
  {
    return number == 0;
  }
}

