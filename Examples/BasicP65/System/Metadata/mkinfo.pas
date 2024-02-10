////////////////////////////////////////////
// New program created in 11-6-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'C000-DFFF'}
{$ORG $0801}
program mkinfo;

uses vfs6502;

type
  str20 = array[20] of char;
  pstr20 = ^str20;

var
  INFO_TITLE: str20;
  IsDownload: boolean;
  infofile: array[60] of char;
  dpath: array[40] of char;
  
  br: array of char = '<br/>';

procedure RunProgram;
begin
  value:=@infofile;
  GetPost(@'infofile');
  if not isNull(value) then
    Write(@'Creating .info file: ');
    WriteLn(@infofile);
    value:=@INFO_TITLE;
    GetPost(@'title');
    if IsPost(@'isdl', @'true') then
      IsDownload:=True;
    else
      IsDownload:=False;
    end;
    SaveFile(@infofile, @INFO_TITLE, Word(21));
    WriteLn(@'Info file created.'); 
    Exit;
  end;
  value:=@dpath;
  GetQuery(@'base');
  Write(@'<h3>mkinfo.prg</h3><hr width="300" align="left">');
  WriteLn(@'<form action="mkinfo.prg" method="post">');
  Write(@'<input type="hidden" name="base" value="');
  Write(@dpath);
  WriteLn(@'"/>');
  Write(@'.info File: <input type="text" value="');
  Write(@'/vfs/System/Metadata/');
  Write(@'" name="infofile" size="40"/>');
  WriteLn(@br);
  Write(@'Content Title: <input type="text" name="title"/>');
  WriteLn(@br);
  Write(@'Is Download: <input type="checkbox" name="isdl" value="true"/>');
  WriteLn(@br);
  Write(@'<input type="submit" name="addit" value="Create .info File"/>');
  WriteLn(@br);
  WriteLn(@'</form>'); 
end; 

procedure wrapper;
begin
  RunProgram;
  asm JMP $fff0 end; 
end; 

begin
  PAGE_TITLE:=@'mkinfo';
  GetContent:=@wrapper;
  Exit;
end.

