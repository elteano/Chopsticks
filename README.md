#Chopsticks

Simulates the number-hand game, sometimes called 'Chopsticks', in a 
server-client setup.

##Compiling

This should be as easy as running

	make all
from within the source directory. This will create a number of object files and 
three executables:
- gameserv, the game server
- client, a terminal-based user client
- spai, an AI client that determines the shortest (although not necessarily the 
	most reliable) path to victory

###Dependencies
Currently, the project uses dmd to compile, and as such that is a dependency. 
Other than the standard D libraries, the project has no library dependencies.

Due to the current nature of the client-server setup, this must be run on a 
platform that supports Unix-domain sockets. Extending functionality to support 
other client-server interfaces should be as simple as creating implementations 
of the ClientInterface and GameInterface interfaces for the appropriate setup, 
and then compiling them into the game server and clients in place of the 
current interfaces.

##Running

First, run the game server. This should create a socket in the current 
directory titled 'asdf.sock'. You may then run the two clients in player order.

###Terminal Client

The terminal client accepts two commands, split and strike. Split accepts no 
arguments, and is used to split the value of one hand over both should one hand 
be set to zero. Strike accepts two arguments of 0 or 1 corresponding to the 
left and right source and target, respectively. For example,

	strike 0 1
will add the value of the player's left hand to the target's right.

