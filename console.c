#include <stdlib.h>
#include <stdio.h>
#include <avr/io.h>
#include <util/setbaud.h>

void console_init(void) __attribute__((naked)) __attribute__((section (".init8")));
static void uart_init(void);
static int uart_putchar(char c, FILE* stream);
static int uart_getchar(FILE* stream);

static FILE uart = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);

void console_init(void)
{
	uart_init();
	stdin = stdout = stderr = &uart;
}

#if defined(UDR)
  #define _UBRRH UBRRH
  #define _UBRRL UBRRL
  #define _UCSRA UCSRA
  #define _UCSRB UCSRB
  #define _UDR   UDR
  #define _U2X   U2X
  #define _RXEN  RXEN
  #define _TXEN  TXEN
  #define _UDRE  UDRE
  #define _RXC   RXC
#elif defined(UDR0)
  #define _UBRRH UBRR0H
  #define _UBRRL UBRR0L
  #define _UCSRA UCSR0A
  #define _UCSRB UCSR0B
  #define _UDR   UDR0
  #define _U2X   U2X0
  #define _RXEN  RXEN0
  #define _TXEN  TXEN0
  #define _UDRE  UDRE0
  #define _RXC   RXC0
#else
  #error "no UART available"
#endif

void uart_init()
{
	_UBRRH = UBRRH_VALUE;
	_UBRRL = UBRRL_VALUE;
	#if USE_2X
	_UCSRA |= (1 << _U2X);
	#else
	_UCSRA &= ~(1 << _U2X);
	#endif
	_UCSRB = _BV(_RXEN) | _BV(_TXEN);
}

int uart_putchar(char c, FILE* stream)
{
	if (c == '\n')
		uart_putchar('\r', stream);
	loop_until_bit_is_set(_UCSRA, _UDRE);
	_UDR = c;
	return 0;
}

int uart_getchar(FILE* stream) 
{
	stream = stream; // unused
	loop_until_bit_is_set(_UCSRA, _RXC);
	return _UDR;
}
