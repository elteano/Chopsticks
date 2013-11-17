import Command, Player;

/**
 * An interface describing the methods by which a player interfaces (poor
 * choice of word, but couldn't think of anything else) with the GameServer.
 * Example implementations of this interface include a UNIX socket interface.
 */
public interface GameInterface
{
  public:
    /**
     * Function call to get a command from a player. Implementations of this
     * command should block until the command returns.
     *
     * Returns: struct Command describing source and destination of the
     * command.
     */
    Command getCommand();
    Command getCommand(ubyte pnum);
    /**
     * Pushes the status of the player from the GameServer to the players.
     * Implementations of this function should immediately inform all clients
     * of the change.
     *
     * Params:
     * playerOne = object describing the first player
     * playerTwo = object describing the second player
     * turn = uint describing who's turn; if even, it is player one's turn, if
     * odd, it is player two's turn.
     * Examples:
     * -------------
     * // push hand values for players, it is player 2's turn
     * pushStatus(p1, p2, 5);
     * -------------
     */
    void pushStatus(Player playerOne, Player playerTwo, ubyte turn);
    /**
     * Informs the GameInterface that it ought to do its initialization tasks.
     *
     * This may not be necessary for some interfaces. An example implementation
     * of this would be for a socket-based interface, for which this function
     * would listen for incoming connetions.
     */
    void initialize();
}

