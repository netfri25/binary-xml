all: encode decode

encode: encode.asm Makefile
	fasm $< $@

decode: decode.asm Makefile
	fasm $< $@

clean:
	rm -f encode decode

.PHONY: all clean
