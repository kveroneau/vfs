////////////////////////////////////////////
// New program created in 16-12-23}
////////////////////////////////////////////
{$SET_DATA_ADDR '5000-6fff'}
program mkvideo;

uses vfs6502;
  
type
  str80 = array[80] of char;
  str40 = array[40] of char;

var
  vidfile: str40;
  title: str40;
  ytlink: str40;
  views: word;
  body: array[4096] of char;
  fsize: word;

procedure RunApp;
begin
  WriteLn(@'mkvideo.prg<br/>');
  WriteLn(@'<form action="mkvideo.prg" method="post">');
  WriteLn(@'VID File: <input type="text" name="vidfile"/><br/>');
  WriteLn(@'Title: <input type="text" name="title"/><br/>');
  WriteLn(@'URL for video: <input type="text" name="url"/><br/>');
  WriteLn(@'<textarea name="comments" rows="15" cols="60"></textarea>');
  WriteLn(@'<br/><input type="submit" value="Create Video"/></form>');
  EndRequest;
end; 

begin
  value:=@vidfile;
  GetPost(@'vidfile');
  if not isNull(value) then
    value:=@title;
    GetPost(@'title');
    value:=@ytlink;
    GetPost(@'url');
    views:=0;
    MemClear(@body, 4096);
    value:=@body;
    GetPost(@'comments');
    fsize:=StrLength(@body);
    fsize:=fsize+83;
    SaveFile(@vidfile, @title, fsize);
    REDIRECT:=@'/vfs/tests/';
    Exit;
  end;
  GetContent:=@RunApp;
  PAGE_TITLE:=@'mkvideo.prg';
  SITE_HEADER:=0;
  Exit; 
end.

