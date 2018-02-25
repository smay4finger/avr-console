#include <stdlib.h>
#include <stdio.h>
#include <avr/io.h>
#include <avr/pgmspace.h>

int main(void)
{
	for(;;) {
		printf_P(PSTR("Hello World!\n"));

		fprintf_P(stderr, PSTR("Hello World! to stderr\n"));

		char foo = getc(stdin);

		printf_P(PSTR("You entered: %c\n"), foo);
	}
	return 0;
}
