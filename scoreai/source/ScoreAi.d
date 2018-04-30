import std.algorithm.comparison;
import std.stdio;
import std.typecons;

import ClientDecider;
import Command;
import convenience;
import GenericClient;
import InetClient;
import SocketClient;
import StatusMessage;
import StatusPrefix: StatusPrefix;

/**
 * A new take on the shortest-path AI which uses a more efficient algorithm for
 * determining the best path than the strange tree thing. This instead uses an
 * array to store score values for each possible game configuration, and then
 * propagates those through other possible scoring configurations until we get
 * some good paths.
 */
public class ScoreAi : ClientDecider
{
  private:
    const real DEGEN_FACTOR = 0.9;
    const real LOSING_SCORE = -20;
    const real WINNING_SCORE = 10;
    // Start with |V|^2
    const ulong NUM_ITERATIONS = 48 * 48 * 24 * 24;

    /**
     * A set of scores for various game configurations, assuming that the
     * player may make no choices. It is used in order to find the most
     * desirable action on the player's turn.
     *
     * Row indices correspond to me.
     * Column indices correspond to the foe.
     * Row indices past 25 correspond to my turn, where row indices prior to 25
     * correspond to the foe's turn.
     */
    real[50][25] values;

    auto decodeRowIndex(size_t index)
    {
      return tuple(index / 5, index % 5);
    }

    auto decodeColIndex(size_t index)
    {
      bool myTurn = false;
      if (index >= 25)
      {
        myTurn = true;
        index -= 25;
      }
      return tuple(index / 5, index % 5, myTurn);
    }

    size_t getIndex(ubyte left, ubyte right)
    {
      return left * 5 + right;
    }

    /**
     * Initialize the values before any routing passes have been made.
     */
    void initValues()
    {
      // Everything defaults to a zero value
      foreach (ref r; values )
      {
        foreach (ref c; r)
        {
          c = 0.0;
        }
      }

      // Initialize losing values and winning values
      for (size_t goods = 0; goods < 25; ++goods)
      {
        values[goods][0] = WINNING_SCORE;
        values[0][goods] = LOSING_SCORE;
        // Cover the "our turn" case as well
        values[0][goods + 25] = -20;
      }
    }

    /**
     * Propagate scoring throughout the box.
     */
    void scoringPass()
    {
      for (size_t r = 1; r < 25; ++r)
      {
        size_t ml = r / 5;
        size_t mr = r % 5;
        /* Scores for their turn
         * We assume (incorrectly) that they will make a random decision
         * There are one to five possible actions they may take, and we want to
         * weight this properly
         */
        for (size_t c = 1; c < 25; ++c)
        {
          real total_score = 0;
          ubyte possible_moves = 0;
          size_t el = c / 5;
          size_t er = c % 5;
          // First, do they have a left
          if (el > 0)
          {
            // Can they attack our left
            if (ml > 0)
            {
              size_t ind = (r + el * 5) % 25;
              total_score += values[ind][c + 25];
              ++possible_moves;
            }
            // Can they attack our right
            if (mr > 0)
            {
              size_t ind = ml * 5 + ((mr + el) % 5);
              total_score += values[ind][c + 25];
              ++possible_moves;
            }
          }
          // Otherwise, can they split their right
          else
          {
            if (er % 2 == 0)
            {
              // (er / 2) * 5 + (er / 2) = er * 3
              size_t ind = (er * 3) % 25 + 25;
              total_score += values[r][ind];
              ++possible_moves;
            }
          }
          // Then, do they have a right
          if (er > 0)
          {
            // Right -> Left
            if (ml > 0)
            {
              size_t ind = (r + er * 5) % 25;
              total_score += values[ind][c + 25];
              ++possible_moves;
            }
            if (mr > 0)
            {
              size_t ind = ml * 5 + (mr + er) % 5;
              total_score += values[ind][c + 25];
              ++possible_moves;
            }
          }
          // Otherwise, can they split their left
          else if (el % 2 == 0)
          {
            // (el / 2) * 5 + (el / 2) = el * 3
            size_t ind = (el * 3) % 25 + 25;
            total_score += values[r][ind];
            ++possible_moves;
          }
          // Now, update the score for the current location
          values[r][c] = (total_score / possible_moves) * DEGEN_FACTOR;
        }
        /* Scores for our turn
         * This will always be the maximum score we can reach from this point,
         * since we have control over where we go
         */
        for (size_t c = 26; c < 50; ++c)
        {
          real max_score = -real.max;
          size_t ec = c - 25;
          size_t el = ec / 5;
          size_t er = ec % 5;
          // Can we hit with our left
          if (ml > 0)
          {
            // Can we hit left -> left
            if (el > 0)
            {
              size_t ind = (ec + ml * 5) % 25;
              max_score = max(max_score, values[r][ind]);
            }
            // Can we hit left -> right
            if (er > 0)
            {
              size_t ind = el * 5 + (er + ml) % 5;
              max_score = max(max_score, values[r][ind]);
            }
          }
          // Can we split right -> left
          else if (mr % 2 == 0)
          {
            size_t ind = er * 3 % 25;
            max_score = max(max_score, values[ind][ec]);
          }
          // Can we hit with our right
          if (mr > 0)
          {
            // Can we hit right -> left
            if (el > 0)
            {
              size_t ind = (ec + mr * 5) % 25;
              max_score = max(max_score, values[r][ind]);
            }
            // Can we hit right -> right
            if (er > 0)
            {
              size_t ind = el * 5 + (er + mr) % 5;
              max_score = max(max_score, values[r][ind]);
            }
          }
          // Can we split left -> right
          else if (ml % 2 == 0)
          {
            size_t ind = el * 3 % 25;
            max_score = max(max_score, values[ind][ec]);
          }
          // Set score for our current location
          values[r][c] = max_score * DEGEN_FACTOR;
        }
      }
    }

  public:
    this()
    {
      initValues();
      for (ulong i = 0; i < NUM_ITERATIONS; ++i)
      {
        scoringPass();
      }
      writeln("Enemy turn values");
      foreach (row; values)
      {
        foreach (col; row[0 .. 25])
        {
          writef("%.2f\t", col);
        }
        writeln();
      }
      writeln();
      writeln("My turn values");
      foreach (row; values)
      {
        foreach (col; row[25 .. row.length])
        {
          writef("%.2f\t", col);
        }
        writeln();
      }
    }

    Command getNextPlay(ubyte p_num, StatusMessage currentTurn)
    {
      Command ret;
      ret.prefix = StatusPrefix.PLAY_INCOMING;
      ubyte ml = 0;
      ubyte mr = 0;
      ubyte el = 0;
      ubyte er = 0;
      if (p_num == 0)
      {
        ml = currentTurn.p1h1;
        mr = currentTurn.p1h2;
        el = currentTurn.p2h1;
        er = currentTurn.p2h2;
      }
      else // assume p_num == 1
      {
        ml = currentTurn.p2h1;
        mr = currentTurn.p2h2;
        el = currentTurn.p1h1;
        er = currentTurn.p1h2;
      }
      // Determine best destination
      real max_score = -real.max;
      size_t r = ml * 5 + mr;
      size_t c = el * 5 + er;
      // Left strikes
      if (ml > 0)
      {
        // Left -> Left
        if (el > 0)
        {
          size_t ind = (el + ml) % 5 * 5 + er;
          writefln("Strike left -> left has score %f.", values[r][ind]);
          if (values[r][ind] > max_score)
          {
            max_score = values[r][ind];
            ret.directive = CommandDirective.STRIKE;
            ret.src_hand = HandIdentifier.LEFT;
            ret.tgt_hand = HandIdentifier.LEFT;
            writeln("I like this!");
          }
        }
        // Left -> Right
        if (er > 0)
        {
          size_t ind = el * 5 + (er + ml) % 5;
          writefln("Strike left -> right has score %f.", values[r][ind]);
          if (values[r][ind] > max_score)
          {
            max_score = values[r][ind];
            ret.directive = CommandDirective.STRIKE;
            ret.src_hand = HandIdentifier.LEFT;
            ret.tgt_hand = HandIdentifier.RIGHT;
            writeln("I like this!");
          }
        }
      }
      // Split Right -> Left
      else if (mr % 2 == 0)
      {
        size_t ind = mr * 3 % 25;
        writefln("Split right -> left has score %f.", values[ind][c]);
        if (values[ind][c] > max_score)
        {
          max_score = values[ind][c];
          ret.directive = CommandDirective.SPLIT;
          writeln("I like this!");
        }
      }
      // Right strikes
      if (mr > 0)
      {
        // Right -> Left
        if (el > 0)
        {
          size_t ind = (el + mr) % 5 * 5 + er;
          writefln("Strike right -> left has score %f.", values[r][ind]);
          if (values[r][ind] > max_score)
          {
            max_score = values[r][ind];
            ret.directive = CommandDirective.STRIKE;
            ret.src_hand = HandIdentifier.RIGHT;
            ret.tgt_hand = HandIdentifier.LEFT;
            writeln("I like this!");
          }
        }
        // Right -> Right
        if (er > 0)
        {
          size_t ind = el * 5 + (er + mr) % 5;
          writefln("Strike right -> right has score %f.", values[r][ind]);
          if (values[r][ind] > max_score)
          {
            max_score = values[r][ind];
            ret.directive = CommandDirective.STRIKE;
            ret.src_hand = HandIdentifier.RIGHT;
            ret.tgt_hand = HandIdentifier.RIGHT;
            writeln("I like this!");
          }
        }
      }
      // Split Left -> Right
      else if (ml % 2 == 0)
      {
        size_t ind = ml * 3 % 25;
        writefln("Split left -> right has score %f.", values[ind][c]);
        if (values[ind][c] > max_score)
        {
          max_score = values[ind][c];
          ret.directive = CommandDirective.SPLIT;
          writeln("I like this!");
        }
      }
      return ret;
    }
}

public void main(string[] args)
{
  SocketClient sc = new InetClient("localhost", 31718);
  ubyte pNum = sc.initialize();
  ScoreAi ai = new ScoreAi();
  GenericClient client = new GenericClient(ai, sc, pNum);
  client.gameLoop();
}
