CLIENT_OBJS=Command.o StatusMessage.o TerminalUser.o ClientInterface.o \
						UnixClient.o
SERV_OBJS=GameServer.o Command.o Hand.o Player.o Game.o GameInterface.o \
					UnixInterface.o StatusMessage.o

%.o: %.d
	dmd -g -c $<

.PHONY: all
all: gameserv client

gameserv: $(SERV_OBJS)
	dmd -g -ofgameserv $(SERV_OBJS)

client: $(CLIENT_OBJS)
	dmd -g -ofclient $(CLIENT_OBJS)

.PHONY: clean
clean:
	rm *.o gameserv client

