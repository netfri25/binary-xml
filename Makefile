BUILD_DIR = build

all: encode decode

$(BUILD_DIR): Makefile
	mkdir $@

encode: src/encode.asm Makefile build
	fasm $< $(BUILD_DIR)/$@

decode: src/decode.asm Makefile build
	fasm $< $(BUILD_DIR)/$@

clean:
	rm -f encode decode

.PHONY: all clean
