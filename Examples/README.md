# VFS 6502 Example siteroot/

Each VFS website built using this web engine needs to have a `siteroot/` directory, and this document will explain it's structure, as well as an environment variable which can be set which is used to set a root within this directory to either allow the VFS to be hosted in a subdirectory on a domain, eg. `https://www.veroneau.net/vfs/`, or directly in the root, as with most stand-alone websites.

Under `siteroot/`, you will also need a `sessions/` directory, which will store the server-side sessions for each connected user.  These are where the so-called *session variables* are stored, which is why if you run it as a root application, instead of say in `/vfs/`, you should take precaution to secure this directory via your web server configuration if the VFS is deployed on a public facing website.

Depending if your VFS is in a subdomain or not, the main root of your file-system should have the following structure:

  * **BOOT.SYS** The initial 6502 program to run on each server start.
  * **System/** The VFS System Directory, where all the critical system files are.
  * **System/Widgets/nav-pane.widget** is basically an HTML file which gets rendered to the `{{navbar}}` template tag.
  * **System/Settings/Icons.conf** is where you can customize how icons are displayed.
  * **System/Metadata/** A global storage directory which `.info` files are checked.

### Example/Starter VFS

In this directory there are several different VFS starters to choose from.  Of course, you can just roll your own completely, building your own `BOOT.SYS` in your preferred 6502 assembler or compiler and have at it.  These examples will grow over time.  Here is a list of what is currently on offer:

  * `BasicP65`: A `siteroot/` which will run from the `vfs/` subdirectory of an existing server.  This can be changed by rebuilding the source to be without `vfs/`.  If setting up a server with it, the files inside this directory should be placed under `siteroot/vfs/`, the working directory set for the VFS to run in.
    - This site root is meant to allow easy coding of the system in P65Pas, the 6502 Pascal compiler.  The boot program and all utilities in the VFS are all written in Pascal.  You can still compile C and assembly programs which can run in this VFS of course, as the programs don't yet use a specific API system, other than the VFS API.
  * `BasicC`: A `siteroot/` which will run from the `vfs/` subdirectory of an existing server.  All the main source code for each program is in `siteroot/`, and then the `vfs/` directory exists here where the `Makefile` will move all the compiled files into.
    - This is a C-based version in very early development, but is still pretty capable.  It does not have as many utilities as the Pascal version, but it will soon have it's own set of unique features to separate itself from a VFS running in Pascal.
    - This can work as a good base for seasoned 6502 developers who have worked with 6502 C and assembly in the past.
