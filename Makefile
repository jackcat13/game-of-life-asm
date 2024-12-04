game: game.o
	ld -o target/game build/game.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

game.o: game.s
	as -o build/game.o game.s