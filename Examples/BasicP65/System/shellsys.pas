////////////////////////////////////////////
// New program created in 28-7-23}
////////////////////////////////////////////
{$OUTPUTHEX 'SHELL.SYS'}
{$SET_DATA_ADDR '0400-07FF'}
program shellsys;

uses vfs6502;
{$ORG $ea00}

type
  str80 = array[80] of char;

var
  ext: array[5] of char;
  path: array[40] of char;
  buf: array[8000] of char absolute $2000;
  URL: str80;

procedure HandleWebLink;
begin
  LoadFile(@path, @URL);
  REDIRECT:=@URL;
end;

begin
  SITE_HEADER:=0;
  if StrEqual(@ext, @'.lnk') then
    HandleWebLink;
    Exit;
  end; 
  if StrEqual(@ext, @'.md') then
    LoadFile(@'System/libmarkdown.OVL', $2000);
    asm jmp $2000 end;
  end; 
  WriteLn(@'SHELL.SYS initialized.<br/>');
  Write(@'Ext: ');
  WriteLn(@ext);
  value:=@path;
  GetPathInfo;
  Write(@'<br/>Path: ');
  WriteLn(@path);
  if IsSession(@'login', ADMIN_PASS) then
    if StrEqual(@ext, @'.pas') then
      Write(@'<hr/><textarea style="width: 800px; height: 600px;">');
      LoadFile(@path, @buf);
      WriteLn(@buf);
      WriteLn(@'</textarea>');
    end;
  end;
  Exit;
end.

