#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

int main(void) {
    char c;
    uint8_t index = 0;
    uint8_t byte = 0;

    while ((c = fgetc(stdin)) == '<') {
        bool set;

        switch (fgetc(stdin)) {
            case 'o': {
                if (fgetc(stdin) != 'n' || fgetc(stdin) != 'e' || fgetc(stdin) != '/' || fgetc(stdin) != '>')
                    goto err;

                set = true;
            } break;

            case 'z': {
                if (fgetc(stdin) != 'e' || fgetc(stdin) != 'r' || fgetc(stdin) != 'o' || fgetc(stdin) != '/' || fgetc(stdin) != '>')
                    goto err;

                set = false;
            } break;

            default: goto err;
        }

        byte |= set << index;
        index += 1;
        index %= 8 * sizeof byte;
        if (index == 0) {
            fputc(byte, stdout);
            byte = 0;
        }
    }

    if (c != EOF || index != 0) goto err;

    return 0;

err:
    fprintf(stderr, "unable to parse file");
    return 1;
}
