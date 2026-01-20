/* This is the asembly code that is the entry point of the kernel : it sets things
up so the C code can execute (kernel_main call)*/

/* Multiboot header constants */
.set ALIGN,    1<<0             /* (align flag) align loaded modules on page boundaries (starts at a memory block) */
.set MEMINFO,  1<<1             /* asks memory map to bootloader */
.set FLAGS,    ALIGN | MEMINFO
.set MAGIC,    0x1BADB002       /* magic number to indicate multiboot to bootloader */
.set CHECKSUM, -(MAGIC + FLAGS) /* integrity check */

/* Multiboot header section */
.section .multiboot
.align 4                /* align on 4 octets boundaries */
/* writes the following raw memory */
.long MAGIC
.long FLAGS
.long CHECKSUM

/* Stack section */
.section .bss
.align 16                       /* align on 16 octets boundaries */
stack_bottom:
.skip 16384                     /* 16 KB stack reserved for uninitialized data */
stack_top:

/* Text section */
.section .text
.global _start                  /* we precise the linking of _start */
.type _start, @function         /* we precise the type of _start */
_start:
    mov $stack_top, %esp        /* Initializes stack pointer on %esp (stack registry) */

    call kernel_main

    cli                         /* disables interrupts (because we can't handle them yet) */
1:  hlt                         /* "1" is a label (sort of variable) that is reusable in other scopes, "hlt" for halt of the CPU */
    jmp 1b                      /* "1b" label for "1 backward", so we jump back if something rwakes up */
