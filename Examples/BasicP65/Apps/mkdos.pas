////////////////////////////////////////////
// New program created in 27-7-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'C000-C3FF'}
program mkdos;

uses vfs6502;

type
  str20 = array[20] of char;
  str40 = array[40] of char;

var
  dosfile: str40;
  DOS_TITLE: str40;
  DOS_IMG: str40;
  DOS_EXE: str20;
  DOS_PATH: str20;

procedure RunApp;
begin
  WriteLn(@'mkdos.prg welcomes you!<br/>');
  WriteLn(@'<form action="mkdos.prg" method="post"/>');
  WriteLn(@'DOS File: <input type="text" name="dosfile"/><br/>');
  WriteLn(@'App Title: <input type="text" name="title"/><br/>');
  WriteLn(@'App Image: <input type="text" name="img"/><br/>');
  WriteLn(@'App Exe: <input type="text" name="exe"/><br/>');
  WriteLn(@'App Path: <input type="text" name="mp"/><br/>');
  WriteLn(@'<input type="submit" value="Create file"/></form>');
  EndRequest;
end; 

procedure AppendStr(dst, src: pointer);
begin
  asm 
	  LDA dst
    STA $20
    LDA dst+1
    STA $21
    LDY #0
loop: LDA ($20), Y
      BEQ done
      INY
      BNE loop
done: 
  end; 
end; 

begin
  value:=@dosfile;
  GetPost(@'dosfile');
  if not isNull(value) then
    value:=@DOS_TITLE;
    GetPost(@'title');
    value:=@DOS_IMG;
    GetPost(@'img');
    value:=@DOS_EXE;
    GetPost(@'exe');
    value:=@DOS_PATH;
    GetPost(@'mp');
    SaveFile(@dosfile, @DOS_TITLE, Word(120));
    {AppendStr(@dosfile, @'.info');}
    REDIRECT:=@'/vfs/tests/mkinfo.prg?dpath=/vfs/tests/';
    Exit;
  end; 
  GetContent:=@RunApp;
  PAGE_TITLE:=@'mkdos.prg';
  SITE_HEADER:=0;
  Exit;
end.
