#!/bin/bash
# Script d'installation du cross-compiler i686-elf
# Base sur: https://wiki.osdev.org/GCC_Cross-Compiler

set -e

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

BINUTILS_VERSION="2.41"
GCC_VERSION="13.2.0"

echo "=== Installation du cross-compiler i686-elf ==="
echo "Prefix: $PREFIX"
echo "Target: $TARGET"
echo ""

# Dependances
echo "[1/6] Installation des dependances..."
sudo apt-get update
sudo apt-get install -y build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo

# Creer les repertoires
mkdir -p "$PREFIX"
mkdir -p /tmp/cross-build
cd /tmp/cross-build

# Telecharger binutils
echo "[2/6] Telechargement de binutils-$BINUTILS_VERSION..."
if [ ! -f "binutils-$BINUTILS_VERSION.tar.xz" ]; then
    wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz"
fi
tar xf "binutils-$BINUTILS_VERSION.tar.xz"

# Compiler binutils
echo "[3/6] Compilation de binutils..."
mkdir -p build-binutils
cd build-binutils
../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make -j$(nproc)
make install
cd ..

# Telecharger GCC
echo "[4/6] Telechargement de gcc-$GCC_VERSION..."
if [ ! -f "gcc-$GCC_VERSION.tar.xz" ]; then
    wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz"
fi
tar xf "gcc-$GCC_VERSION.tar.xz"

# Compiler GCC
echo "[5/6] Compilation de GCC (cela peut prendre 20-30 minutes)..."
mkdir -p build-gcc
cd build-gcc
../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c --without-headers
make -j$(nproc) all-gcc
make -j$(nproc) all-target-libgcc
make install-gcc
make install-target-libgcc
cd ..

echo "[6/6] Nettoyage..."
cd ~
rm -rf /tmp/cross-build

echo ""
echo "=== Installation terminee ==="
echo ""
echo "Ajoute cette ligne a ton ~/.bashrc :"
echo "  export PATH=\"\$HOME/opt/cross/bin:\$PATH\""
echo ""
echo "Puis execute: source ~/.bashrc"
echo ""
echo "Verifie avec: i686-elf-gcc --version"
