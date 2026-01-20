/* Linker script for the kernel - following OSDev Bare Bones ;
it is used to organize the memory for the kernel */

ENTRY(_start)

SECTIONS
{
    /* Kernel loaded at 2MB (OSDev recommendation) */
    /* first 1–2 MB are used by : BIOS, GRUB, multiboot structs */
    . = 2M;

    /* Text section includes multiboot header */
    /* aligned at 4096 bytes boundaries and the section is rounded to a 4096 bytes segment */
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
        *(COMMON) /* for global uninitialized variables */
        *(.bss)
    }
}
