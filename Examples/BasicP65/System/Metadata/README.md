# VFS File Metadata

This directory is scanned much like how the `PATH` variable works on your PC.  If the VFS cannot find a `.info` metadata for the file being accessed, it will then check this global VFS directory here for the metadata and use it if found.  This both allows the metadata to be centralized, and also removed the clutter that having a ton of `.info` files everywhere, something I noticed during my beta testing and found annoying.  Anyways, there is also a program in this directory which you can use to generate said `.info` files too.

The fields should be pretty self-explanatory:

  * **.info file**: This should be the filename with `.info`, for example, `myfile.zip.info` is the metadata for `myfile.zip`.
  * **Content Title**: can be used by a program or is otherwise shown when a user attempts to download the file.
  * **Is Download**: This will essentially force the download on the user-end, and also allow the file to be downloaded in the first place.  In every case, if you just willy nilly upload a file, and if the VFS doesn't support it's file-type, it won't act like a traditional static web server and willingly just hand the file over to the user.  Instead, the VFS requires that an Admin on the site create a proper metadata file for each file they are wanting to allow others to download.  Metadata is not required for any file which is handled by the VFS, and if a user say wanted to make every `.zip` file downloadable by default, that is completely possible, either via a *hook* or by using the new *SHELL.SYS* feature.
