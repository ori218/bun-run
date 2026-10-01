.RECIPEPREFIX = >

SRC := $(wildcard src/*.asm)
OBJ := $(patsubst src/%.asm,obj/%.o,$(SRC))
INC := $(wildcard src/*.inc)

game.gb: $(OBJ)
> rgblink -o $@ -n game.sym $^
> rgbfix -v -p 0xFF $@

obj/%.o: src/%.asm $(INC)
> @mkdir -p obj
> rgbasm -I src/ -o $@ $<

clean:
> rm -rf obj game.gb game.sym

.PHONY: clean