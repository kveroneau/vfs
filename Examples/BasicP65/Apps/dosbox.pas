////////////////////////////////////////////
// New program created in 27-7-23}
////////////////////////////////////////////
{$SET_DATA_ADDR '2000-2AFF'}
program dosbox;

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

procedure DosBoxApp;
begin
  Write(@'<div style="text-align: center; font-size: 18px;">');
  Write(@DOS_TITLE);
  WriteLn(@'</div>');
  WriteLn(@'<canvas id="dosapp"></canvas>');
  WriteLn(@'<script src="/s/dosbox.js"></script>');
  WriteLn(@'<script> rtl.run(); </script>');
  EndRequest;
end; 

procedure DosBoxHelp;
begin
  WriteLn(@'Please specify a .dos file.');
  EndRequest;
end; 

begin
  PAGE_TITLE:=@'DOSBox App';
  value:=@dosfile;
  GetQuery(@'file');
  if isNull(value) then
    GetContent:=@DosBoxHelp;
    {SITE_HEADER:=0;}
    Exit;
  end;
  LoadFile(@dosfile, @DOS_TITLE);
  PAGE_TITLE:=@DOS_TITLE;
  GetContent:=@DosBoxApp;
  SITE_HEADER:=@'<script src="/s/js-dos.js"></script><link href="/s/dosapp.css" rel="stylesheet"/>';
  Exit;
end.

