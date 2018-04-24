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

Then you may go into the gameserv and termuser directories and simply

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

###Terminal Client

The terminal client accepts two commands, split and strike. Split accepts no 
arguments, and is used to split the value of one hand over both should one hand 
be set to zero. Strike accepts two arguments of 0 or 1 corresponding to the 
left and right source and target, respectively. For example,

	strike 0 1
will add the value of the player's left hand to the target's right.

