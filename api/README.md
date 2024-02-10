# The VFS 6502 programmer's API

I originally forgot to include these in my original commit of the VFS, and they are super important for anyone wanting to jump in right away, but lacking any way of which to easily program for it.

The `vfs6502.pas` is a unit file meant to be used in the amazing P65Pas cross-platform Pascal 6502 compiler.

The `clib` directory is the source for a cc65 compatible library which can then be used to make VFS 6502 compatible C programs.

The `vfs6502.h` is the C header file, but if you are a C programmer, then you already knew this.  Use this header file with the `cc65` compiler.

The `Makefile` here shows how you can use the `cc65` compiler to effortless compile C programs into usable VFS 6502 programs.
