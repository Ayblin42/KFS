/* Linker script for the kernel - following OSDev Bare Bones */

ENTRY(_start)

SECTIONS
{
    /* Kernel loaded at 2MB (OSDev recommendation) */
    . = 2M;

    /* Text section includes multiboot header */
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.multiboot)
        *(.text)
    }

    /* Read-only data */
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata)
    }

    /* Read-write initialized data */
    .data BLOCK(4K) : ALIGN(4K)
    {
        *(.data)
    }

    /* Read-write uninitialized data (BSS) */
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }
}
