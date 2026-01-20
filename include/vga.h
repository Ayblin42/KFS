#ifndef VGA_H
#define VGA_H
// VGA for Video Graphics Array : it is the simplest way to graphically represent data

#include "kernel.h"

#define VGA_WIDTH   80
#define VGA_HEIGHT  25
// VGA exposes its screen in RAM memory at this address
#define VGA_MEMORY  0xB8000

void terminal_initialize(void);
void terminal_putchar(char c);
void terminal_writestring(const char *data);

#endif
