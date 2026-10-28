ASM      := nasm
CC       := gcc

TARGET   := main
SRC      := src/main.asm
OBJ      := build/main.o

ASMFLAGS := -f elf64 -g -F dwarf
LDFLAGS  := -no-pie -nostartfiles -g

.PHONY: all build run debug clean rebuild

all: $(TARGET)

build: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) -o $(TARGET)

$(OBJ): $(SRC)
	mkdir -p build
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

run: $(TARGET)
	./$(TARGET)

debug: $(TARGET)
	gdb ./$(TARGET)

clean:
	rm -rf build $(TARGET)

rebuild: clean all
