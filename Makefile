# **************************************************************************** #
#                                KFS - Kernel From Scratch                     #
# **************************************************************************** #

NAME		= kfs.bin
ISO			= kfs.iso

# Directories
SRC_DIR		= src
INC_DIR		= include
OBJ_DIR		= obj
ISO_DIR		= iso

# Docker
DOCKER_IMG	= kfs
DOCKER_RUN	= docker run --rm -v "$$(pwd)":/kfs $(DOCKER_IMG)

# Compiler (gcc -m32, pas besoin de cross-compiler)
CC			= gcc
AS			= as
LD			= ld

# Sources
C_SRCS		= $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS	= $(wildcard $(SRC_DIR)/*.s)
C_OBJS		= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRCS))
ASM_OBJS	= $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SRCS))
OBJS		= $(ASM_OBJS) $(C_OBJS)

# Flags (requis par le sujet)
CFLAGS		= -m32 \
			  -std=gnu99 \
			  -ffreestanding \
			  -fno-builtin \
			  -fno-stack-protector \
			  -nostdlib \
			  -nodefaultlibs \
			  -O2 \
			  -Wall \
			  -Wextra \
			  -I$(INC_DIR)

ASFLAGS		= --32
LDFLAGS		= -m elf_i386 -T linker.ld -nostdlib

# **************************************************************************** #
#                                    Regles                                    #
# **************************************************************************** #

.PHONY: all clean fclean re docker iso run verify

# Compilation via Docker (commande par defaut)
all: docker

# Build l'image Docker (une seule fois)
docker-build:
	@docker build -t $(DOCKER_IMG) . > /dev/null 2>&1 || docker build -t $(DOCKER_IMG) .
	@echo "Image Docker $(DOCKER_IMG) prete"

# Compile via Docker
docker: docker-build
	@$(DOCKER_RUN)
	@echo "Compilation terminee: $(NAME)"

# Compilation locale (utilisee par Docker)
build: $(NAME)

$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(NAME)

# Cree l'ISO bootable
iso: docker-build
	@$(DOCKER_RUN)
	@$(DOCKER_RUN) make iso-local
	@echo "ISO creee: $(ISO)"

iso-local: $(NAME)
	@mkdir -p $(ISO_DIR)/boot/grub
	@cp $(NAME) $(ISO_DIR)/boot/
	@cp grub.cfg $(ISO_DIR)/boot/grub/
	@grub-mkrescue -o $(ISO) $(ISO_DIR) 2>/dev/null

# Verifie que le kernel est multiboot compliant
verify: docker-build
	@$(DOCKER_RUN) grub-file --is-x86-multiboot $(NAME) && echo "Multiboot: OK"

# Lance le kernel dans QEMU
run: iso
	qemu-system-i386 -cdrom $(ISO)

# Nettoyage
clean:
	rm -rf $(OBJ_DIR) $(ISO_DIR)

fclean: clean
	rm -f $(NAME) $(ISO)

re: fclean all
