arg1 := $(word 1, $(MAKECMDGOALS))
arg2 := $(word 2, $(MAKECMDGOALS))
arg3 := $(word 3, $(MAKECMDGOALS))
arg4 := $(word 4, $(MAKECMDGOALS))

.PHONY: all matriz seq

all: matriz.c seq.c ../utils.c
	gcc -o matriz.o matriz.c ../utils.c -ansi -pedantic -Wall
	gcc -o seq.o seq.c ../utils.c -ansi -pedantic -Wall
	gcc -o conc.o conc.c ../utils.c -ansi -pedantic -Wall

matriz:
	./matriz.o $(arg2) $(arg3) $(arg4)

seq:
	./seq.o mat$(arg2).bin mat$(arg3).bin matSeq.bin

conc:
	./conc.o $(arg2) mat$(arg3).bin mat$(arg4).bin matConc.bin

mat:
	./matriz.o $(arg3) $(arg3) mat$(arg2).bin

%:
	@:

clean:
	rm -r *.o *.bin