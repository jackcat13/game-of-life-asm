# Context

The purpose of this project is to implement the Conways' Game of Life in Assembly language (Mac Apple Silicon). Why ? Just for the fun and because it's quite amazing to code in Assembly. Also, executing the game of life in terminal is quite cool.

# How to build / run the project

Open your terminal and execute following commands :

```bash
make
./target/game
```

Pre-requisites : `make` and `as` commands should be available in your terminal.

# How it looks

Following is an execution example of the game in the terminal :

https://github.com/user-attachments/assets/06753c86-a9d9-4b62-8b69-86bcb3b25b99

# Different generations

It is possible to change the initial state of the game by passing a single argument to the program (needs to be an int) :

```bash
./target/game 212
```

In this case, 212 is the seed used by the random generator. 

Note : If anything else than a single argument is provided, default seed will be used.