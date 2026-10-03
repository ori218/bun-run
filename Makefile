.RECIPEPREFIX = >

SRC := $(wildcard src/*.asm)
OBJ := $(patsubst src/%.asm,obj/%.o,$(SRC))
INC := $(wildcard src/*.inc)

BunRun.gb: $(OBJ)
> rgblink -o $@ -n BunRun.sym $^ 
> rgbfix -v -p 0xFF -m MBC1+RAM+BATTERY -r 2 -t "BUN RUN" $@

obj/%.o: src/%.asm $(INC)
> @mkdir -p obj
> rgbasm -I src/ -o $@ $<

clean:
> rm -rf obj BunRun.gb BunRun.sym

.PHONY: clean