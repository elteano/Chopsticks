
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
  private ubyte number;

  public:

version(NONE){

  /**
   * Creates a hand with the default starting value of one.
   */
  this()
  {
    this(1);
  }
}

  /**
   * Creates a hand with the given starting value.
   */
  this(ubyte startValue)
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
  ubyte getNumber()
  {
    return number;
  }

  /**
   * Sets the value of the hand to the given number.
   * Params:
   *  number = the new value for the hand.
   */
  void setNumber(ubyte number)
  {
    this.number = number % 5;
  }

  /**
   * Returns true if the hand is available for use. Specifically, this returns
   * true if there are zero fingers active on a hand.
   */
  bool isActive()
  {
    return number != 0;
  }
}

