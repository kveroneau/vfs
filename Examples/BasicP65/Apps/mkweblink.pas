////////////////////////////////////////////
// New program created in 4-9-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'C000-C3FF'}
program mkweblink;

uses vfs6502;

type
  str80 = array[80] of char;
  str40 = array[40] of char;

var
  lnkfile: str40;
  URL: str80;

procedure RunApp;
begin
  WriteLn(@'mkweblink.prg<br/>');
  WriteLn(@'<form action="mkweblink.prg" method="post">');
  WriteLn(@'LNK File: <input type="text" name="lnkfile"/><br/>');
  WriteLn(@'URL for redirect: <input type="text" name="url"/><br/>');
  WriteLn(@'<input type="submit" value="Create Web Link"/></form>');
  EndRequest;
end; 

begin
  value:=@lnkfile;
  GetPost(@'lnkfile');
  if not isNull(value) then
    value:=@URL;
    GetPost(@'url');
    SaveFile(@lnkfile, @URL, Word(80));
    REDIRECT:=@'/vfs/tests/';
    Exit;
  end;
  GetContent:=@RunApp;
  PAGE_TITLE:=@'mkweblink.prg';
  SITE_HEADER:=0;
  Exit; 
end.
