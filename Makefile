game: game.o
	ld -o target/game build/print.o build/rand.o build/game.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

game.o: game.s
	as -o build/print.o print.s
	as -o build/game.o game.s
	as -o build/rand.o rand.s