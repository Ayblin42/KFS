#include "vga.h"

static size_t terminal_row;
static size_t terminal_column;
static uint16_t *terminal_buffer;

#define VGA_COLOR 0x07  /* Light grey on black */

void terminal_initialize(void)
{
    terminal_row = 0;
    terminal_column = 0;
    terminal_buffer = (uint16_t *)VGA_MEMORY;

    for (size_t i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
        terminal_buffer[i] = ' ' | (VGA_COLOR << 8);
}

void terminal_putchar(char c)
{
    if (c == '\n') {
        terminal_column = 0;
        terminal_row++;
        return;
    }

    terminal_buffer[terminal_row * VGA_WIDTH + terminal_column] = c | (VGA_COLOR << 8);
    terminal_column++;

    if (terminal_column >= VGA_WIDTH) {
        terminal_column = 0;
        terminal_row++;
    }
}

void terminal_writestring(const char *data)
{
    for (size_t i = 0; i < strlen(data); i++)
        terminal_putchar(data[i]);
}
