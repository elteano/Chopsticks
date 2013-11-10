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
     * Instructs the client to perform initialization tasks.
     */
    void initialize();
}

