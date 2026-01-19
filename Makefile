# **************************************************************************** #
#                            KFS - Kernel From Scratch                         #
# **************************************************************************** #

NAME        = kfs.bin
ISO         = kfs.iso

# **************************************************************************** #
#                                 CONFIGURATION                                #
# **************************************************************************** #

SRC_DIR     = src
INC_DIR     = include
OBJ_DIR     = obj
ISO_DIR     = iso

CC          = gcc
AS          = as
LD          = ld

CFLAGS      = -m32 -std=gnu99 -ffreestanding -fno-builtin \
              -fno-stack-protector -nostdlib -nodefaultlibs \
              -O2 -Wall -Wextra -I$(INC_DIR)
ASFLAGS     = --32
LDFLAGS     = -m elf_i386 -T linker.ld -nostdlib

C_SRCS      = $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS    = $(wildcard $(SRC_DIR)/*.s)
OBJS        = $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SRCS)) \
              $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRCS))

# **************************************************************************** #
#                      COMMANDES UTILISATEUR (sur l'hôte)                      #
#                                                                              #
#   make       → compile le kernel via Docker                                  #
#   make iso   → compile + crée l'ISO bootable                                 #
#   make run   → compile + crée ISO + lance QEMU                               #
#   make clean → supprime les fichiers générés                                 #
#                                                                              #
# **************************************************************************** #

DOCKER_IMG  = kfs
DOCKER      = docker run --rm -v "$$(pwd)":/kfs $(DOCKER_IMG)

.PHONY: all iso run verify clean fclean re

all: _docker_build
	@$(DOCKER)
	@echo "✓ $(NAME)"

iso: _docker_build
	@$(DOCKER) make _iso
	@echo "✓ $(ISO)"

run: iso
	qemu-system-i386 -cdrom $(ISO)

verify: _docker_build
	@$(DOCKER) grub-file --is-x86-multiboot $(NAME) && echo "✓ Multiboot OK"

clean:
	rm -rf $(OBJ_DIR) $(ISO_DIR)

fclean: clean
	rm -f $(NAME) $(ISO)

re: fclean all

# Build l'image Docker si nécessaire
_docker_build:
	@docker build -t $(DOCKER_IMG) . -q > /dev/null 2>&1 || docker build -t $(DOCKER_IMG) .

# **************************************************************************** #
#                      COMMANDES INTERNES (dans Docker)                        #
#                                                                              #
#   Ces cibles sont appelées automatiquement par Docker.                       #
#   Ne pas les utiliser directement.                                           #
#                                                                              #
# **************************************************************************** #

.PHONY: build _iso

# Cible par défaut dans Docker (voir Dockerfile CMD)
build: $(NAME)

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(NAME)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

_iso: $(NAME)
	@mkdir -p $(ISO_DIR)/boot/grub
	@cp $(NAME) $(ISO_DIR)/boot/
	@cp grub.cfg $(ISO_DIR)/boot/grub/
	@grub-mkrescue -o $(ISO) $(ISO_DIR) 2>/dev/null
