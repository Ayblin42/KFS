FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-multilib \
    nasm \
    grub-pc-bin \
    grub-common \
    xorriso \
    mtools \
    qemu-system-x86 \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /kfs

# Default command
CMD ["make", "build"]
