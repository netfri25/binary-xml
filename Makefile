BUILD_DIR = build

all: encode decode

$(BUILD_DIR): Makefile
	mkdir $@

encode: src/encode.asm src/common.asm Makefile
	fasm $< $(BUILD_DIR)/$@

decode: src/decode.asm src/common.asm Makefile
	fasm $< $(BUILD_DIR)/$@

clean:
	rm -f encode decode

.PHONY: all clean
