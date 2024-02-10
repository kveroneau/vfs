////////////////////////////////////////////
// New program created in 4-9-23}
////////////////////////////////////////////
program weblink;

uses vfs6502;

var
  lnkfile: array[40] of char;
  URL: array[80] of char;
  
begin
  value:=@lnkfile;
  GetQuery(@'file');
  if isNull(value) then
    WriteLn(@'No LNK file provided.');
    Exit;
  end;
  LoadFile(@lnkfile, @URL);
  REDIRECT:=@URL;
  Exit;
end.
