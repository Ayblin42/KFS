# Kernel From Scratch 1 - Makefile
# Following OSDev Wiki Bare Bones tutorial

# Kernel name
NAME = kfs.bin
ISO = kfs.iso
IMG = kfs.img

# Directories
SRC_DIR = src
INC_DIR = include
OBJ_DIR = obj
ISO_DIR = iso

# Cross-compiler (as recommended by OSDev)
CC = i686-elf-gcc
AS = i686-elf-as
LD = i686-elf-gcc

# Source files
C_SRCS = $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS = $(wildcard $(SRC_DIR)/*.s)

# Object files
C_OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRCS))
ASM_OBJS = $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SRCS))
OBJS = $(ASM_OBJS) $(C_OBJS)

# Flags (as required by the subject and OSDev)
CFLAGS = -std=gnu99 \
         -ffreestanding \
         -fno-builtin \
         -fno-stack-protector \
         -nostdlib \
         -nodefaultlibs \
         -O2 \
         -Wall \
         -Wextra \
         -I$(INC_DIR)

ASFLAGS =

LDFLAGS = -T linker.ld \
          -ffreestanding \
          -O2 \
          -nostdlib

# Phony targets
.PHONY: all clean fclean re iso img run run-img

# Default target
all: $(NAME)

# Create object directory
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# Compile C files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble ASM files (GNU AS syntax)
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# Link all objects into kernel binary
$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(NAME) -lgcc

# Verify multiboot compliance
verify: $(NAME)
	grub-file --is-x86-multiboot $(NAME) && echo "Multiboot: OK"

# Create bootable ISO with GRUB
iso: $(NAME)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(NAME) $(ISO_DIR)/boot/
	cp grub.cfg $(ISO_DIR)/boot/grub/
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# Create minimal bootable disk image (requires sudo)
img: $(NAME)
	sudo ./create_image.sh

# Run with QEMU (ISO)
run: iso
	qemu-system-i386 -cdrom $(ISO)

# Run with QEMU (disk image)
run-img: $(IMG)
	qemu-system-i386 -hda $(IMG)

# Clean object files
clean:
	rm -rf $(OBJ_DIR)

# Full clean
fclean: clean
	rm -f $(NAME) $(ISO) $(IMG)
	rm -rf $(ISO_DIR)

# Rebuild
re: fclean all
