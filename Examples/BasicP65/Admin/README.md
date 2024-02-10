# VFS Admin apps

You should use `mkrc.prg` to create a `folder.rc` in this directory to prevent it from being listed without Admin access.  Although each file can still be opened, which is why there is further protections inside the files themselves to ensure they are being opened by the appropriate person.  You can however rename them in your own deployment, or even rename `Admin/` to something else, as long as you also recompile the `FolderRC.OVL` binary with the new path.

Each program in this folder should explain itself and is very straightforward to use.
