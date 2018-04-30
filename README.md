#Chopsticks

Simulates the number-hand game, sometimes called 'Chopsticks', in a
server-client setup.

##Compiling

Previously this was done with GNU Make, although it has since been converted to
use `dub`, as converting to dub seemed to be an easier way to make the build
system cross-platform.

First, you will need to add the chopsticks-common package to your local package
as such:

`dub add-local chopsticks-common`

Then you may go into the gameserv, termuser, and scoreai directories and simply

`dub build`

in order to get everything going.

###Dependencies
Currently, the project uses dmd to compile, and as such that is a dependency.
Other than the standard D libraries, the project has no library dependencies.

It is possible to compile the system to use Unix sockets, although IPv4 sockets
are now the default. When compiling on non-Posix systems, Unix-style sockets
will not be available.

##Running

The game server must be run first, followed by the two players in player order.
The game server does not support match configuration; the first player to
connect will be the first to make a move.

On Windows I have noticed an odd thing in that Git Bash will not work properly
for the terminal users. Running them from the Windows Command Prompt works as
expected.

`dub run` in any directory will build the current directory if necessary and run
the result.

###Terminal Client

The terminal client accepts two commands, split and strike. Split accepts no
arguments, and is used to split the value of one hand over both should one hand
be set to zero. Strike accepts two arguments of 0 or 1 corresponding to the
left and right source and target, respectively. For example,

	strike 0 1
will add the value of the player's left hand to the target's right.

###Score AI

The goal of this guy was to provide the most difficult opponent possible to an
enterprising user. It will take a bit of time to calculate how to crush its
opponent.

The Score AI evaluates every game configuration (except for winning or losing
configurations) in order to determine which move is most likely to make it win
(or, in the worst case, not lose). As it is currently designed, winning
configurations are given a score of 10, and losing configurations a score of -20 -
thus, between a risky quick win and a slow sure win, it is more likely to go for
the sure win. Configurations are evaluated based on the scores of the
destination configurations; when the configuration of an opponent's turn is
evaluated, the AI makes no assumptions about the foe, and scores the
configuration based on the average of all possible destination configurations
based on the opponent's possible moves. When scoring its own configuration, it
takes the highest possible destination configuration's score directly. After
this initial scoring, the score degenerates by 10% so that configurations which
are closer to victory or defeat are skewed higher or lower than configurations
which are more distant.
