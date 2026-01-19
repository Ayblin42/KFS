#include "kernel.h"
#include "vga.h"

size_t strlen(const char *str)
{
    size_t len = 0;
    while (str[len])
        len++;
    return len;
}

void kernel_main(void)
{
    terminal_initialize();
    terminal_writestring("42");

    while (1)
        __asm__ volatile ("hlt");
}
