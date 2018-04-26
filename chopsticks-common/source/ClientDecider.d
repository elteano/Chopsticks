import Command, StatusMessage;

/**
 * Originally intended to be an interface by which Ai could be plug n' played.
 * I then realized that 'get next command' could also go out to a terminal or
 * something rather than an Ai.
 */
public interface ClientDecider
{
  Command getNextPlay(ubyte p_num, StatusMessage status);
}

