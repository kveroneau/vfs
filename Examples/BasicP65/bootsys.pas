////////////////////////////////////////////
// New program created in 4-6-23}
////////////////////////////////////////////
{$OUTPUTHEX 'BOOT.SYS'}
program bootsys;

uses vfs6502;
{$ORG $FA00}

var
  BOOT_VER: byte;
  VFS_VER: byte absolute $fff2;
  VFS_DEBUG: boolean absolute $fff3;
  LoadShell: boolean;
  tagbuf: array[40] of char;

procedure mytag;
begin
  if tagbuf[0] = #0 then
    Write(@'Hello World from the new tag system!');
  else
    Write(@tagbuf);
  end; 
  EndRequest;
end; 

procedure insert;
var
  fsize: word;
  bp: ^byte;
begin
  if tagbuf[0] = #0 then
    Write(@'Cannot insert nothing!');
  else
    fsize:=LoadFile(@tagbuf, $2000);
    fsize:=fsize+$2000;
    bp:=fsize;
    bp^:=0;
    Write($2000);
  end; 
end; 

begin
  asm 
	  LDX #$ff
    TXS
    CLD 
  end;
  BOOT_VER:=4;
  Write(@'Running on VFS Version ');
  WriteWord(Word(VFS_VER));
  if VFS_DEBUG then
    WriteLn(@' - Running in DEBUG Mode.');
    LoadShell:=False;
  else
    WriteLn(@' - Running in RELEASE Mode.');
    LoadShell:=True;
  end; 
  WriteLn(@'System starting...');
  SITE_TITLE:=@'Beta Test VFS';
  ADMIN_PASS:=@'AdminPass';  // Should create a method to hash this.
  FOLDER_VEC:=$f400;
  LoadFile(@'/vfs/System/FolderRC.OVL', FOLDER_VEC);
  WriteLn(@'FolderRC Vector installed.');
  ADMIN_VEC:=$f700;
  LoadFile(@'/vfs/System/AdminRC.OVL', ADMIN_VEC);
  WriteLn(@'AdminRC Vector installed.');
  if LoadShell then
    SHELL_VEC:=$ea00;
    LoadFile(@'/vfs/System/SHELL.SYS', SHELL_VEC);
    WriteLn(@'SHELL Vector installed.');    
  end; 
  {
    An example of how to handle markdown with a Hook instead of a SHELL.SYS.
    AddRunHook(@'.md=/vfs/tests/Markdown.prg');
    WriteLn(@'Installed Markdown file handler.');
  }
  AddRunHook(@'.dos=/vfs/Apps/dosbox.prg');
  WriteLn(@'Installed the DOS file handler.');
  AddRunHook(@'.lnk=/vfs/Apps/weblink.prg');
  WriteLn(@'Installed the LNK file handler.');
  AddRunHook(@'.vid=/vfs/Apps/PlayVideo.prg');
  WriteLn(@'Installed the VID file handler.');
  AddIndex(@'index.html');
  AddIndex(@'index.prg');
  AddIndex(@'index.app');
  AddIndex(@'index.spa');
  WriteLn(@'Added Index pages.');
  {
    Example of how to change the template, can also be changed dynamically at runtime from a standard 6502 program.
    TMPL:=@'vfs/System/Bootstrap.tmpl';
    WriteLn(@'Bootstrap template installed.');
  }
  {
    This makes it so that the template engine is completely bypassed in some cases.
    AJAX:=True;
    WriteLn(@'AJAX Enabled.');
  }
  tagbuf[0]:=#0;
  TagParam:=@tagbuf;
  // Example of how to add new template tags.
  AddTag(@'mytag', @mytag);
  AddTag(@'insert', @insert);
  WriteLn(@'Added template tag.');
  Exit;
end.

