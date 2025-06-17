#include <stdio.h>
#include <stdint.h>

int main(void) {
    char c;
    while (c = fgetc(stdin), !feof(stdin)) {
        for (uint8_t i = 0; i < 8 * sizeof c; i++)
            fprintf(stdout, ((c >> i) & 1) ? "<one/>" : "<zero/>");
    }
    return 0;
}
