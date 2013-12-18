CLIENT_OBJS=Command.o StatusMessage.o TerminalUser.o ClientInterface.o \
						UnixClient.o convenience.o
SERV_OBJS=GameServer.o Command.o Hand.o Player.o Game.o GameInterface.o \
					UnixInterface.o StatusMessage.o convenience.o
AI_OBJS=Command.o ShortestPathAI.o ClientInterface.o treemaker.o wtree.o \
				convenience.o UnixClient.o StatusMessage.o
SUREAI_OBJS=Command.o SurestPathAI.o ClientInterface.o treemaker.o wtree.o \
				convenience.o UnixClient.o StatusMessage.o

.PHONY: all
all: gameserv client spai sureai

%.o: %.d
	dmd -g -c $<

gameserv: $(SERV_OBJS)
	dmd -g -ofgameserv $(SERV_OBJS)

client: $(CLIENT_OBJS)
	dmd -g -ofclient $(CLIENT_OBJS)

spai: $(AI_OBJS)
	dmd -g -ofspai $(AI_OBJS)

sureai: $(SUREAI_OBJS)
	dmd -g -ofsureai $(SUREAI_OBJS)

.PHONY: clean
clean:
	rm *.o gameserv client spai sureai

