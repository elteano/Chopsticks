import Player;

/**
 * Class representing an active game.
 */
public class Game
{
  private:
    Player playerOne;
    Player playerTwo;

  public:
    /**
     * Creates a new game in which each player starts with the given number of
     * fingers on each hand.
     */
    this(ubyte startValue)
    {
      playerOne = new Player(startValue);
      playerTwo = new Player(startValue);
    }

    this()
    {
      this(1);
    }

    Player getPlayerOne()
    {
      return playerOne;
    }

    Player getPlayerTwo()
    {
      return playerTwo;
    }
}

