import Command, StatusMessage;

public interface ClientInterface
{
  public:
    /**
     * Pushes a command to the associated GameInterface.
     */
    void pushCommand(Command c);
    /**
     * Listens for a status update. This should block until a status is
     * returned.
     */
    StatusMessage getStatus();
    /**
     * Instructs the client to perform initialization tasks. This should also
     * listen for the player number of the connected client.
     * Returns:
     * The player number; 0 for player 1, 1 for player 2.
     */
    ubyte initialize();
}

