BUILD_DIR = build

all: $(BUILD_DIR)/encode $(BUILD_DIR)/decode

$(BUILD_DIR)/encode: src/encode.asm src/common.asm Makefile
	@mkdir -p $(BUILD_DIR)
	fasm $< $@

$(BUILD_DIR)/decode: src/decode.asm src/common.asm Makefile
	@mkdir -p $(BUILD_DIR)
	fasm $< $@

clean:
	rm -f $(BUILD_DIR)/encode $(BUILD_DIR)/decode

.PHONY: all clean
