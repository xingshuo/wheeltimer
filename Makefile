CFLAGS = -g3 -O0 -Wall
SHARED := -fPIC --shared
INC = include
SRC = src
BUILD = build

all: $(BUILD)/ltimer.so $(BUILD)/twheel.so

$(BUILD)/ltimer.so: $(SRC)/timer.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -I$(INC)

$(BUILD)/twheel.so: 3rd/twheel.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -I$(INC)

clean:
	rm $(BUILD)/*