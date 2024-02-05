unit vfsinfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

const
  VFS_VERSION=7;
  VFS_DEBUG={$IFDEF DEBUG}True{$ELSE}False{$ENDIF};
  MEM_PARAM1=$40;
  MEM_PARAM2=$42;
  MEM_PARAM3=$44;

  BOOT_ADDR=$fa00;
  SHELL_ADDR=$ea00;

  INFO_DIR = 'System/Metadata/';

implementation

initialization
  WriteLn('VFS Version '+IntToStr(VFS_VERSION));
  WriteLn('Written By: Kevin Veroneau');
  if VFS_DEBUG then
    WriteLn(' * Running in DEBUG mode!');

end.

