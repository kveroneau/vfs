////////////////////////////////////////////
// New program created in 19-6-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'F300-F3FF'}
{$OUTPUTHEX 'AdminRC.OVL'}
program adminrc;

uses vfs6502;
{$ORG $F700}

var
  prefix: array[20] of char;
  pi: array[80] of char;
  ahref: array of char = '<a href="/';
  img: array of char = '"><img src="/icons/';
  border: array of char = '" border="0"/> ';
  folder: array of char = 'folder.gif';
  br: array of char = '<br/>';
  ADMINRC_VER: byte = 4;
  
begin
  PAGE_TITLE:=@'AdminRC';
  LogVersion(Word(ADMINRC_VER));
  value:=@prefix;
  GetPrefix;
  value:=@pi;
  GetPathInfo;
  if FileExists(@'Admin/add-dir.prg') then
    Write(@ahref);
    Write(@prefix);
    Write(@'Admin/add-dir.prg?base=');
    Write(@pi);
    Write(@img);
    Write(@folder);
    Write(@border);
    Write(@'Create Directory</a>');
    WriteLn(@br);
  end;
  if FileExists(@'Admin/addpage.prg') then
    Write(@ahref);
    Write(@prefix);
    Write(@'Admin/addpage.prg?base=');
    Write(@pi);
    Write(@img);
    Write(@'layout.gif');
    Write(@border);
    Write(@'Create File</a>');
    WriteLn(@br);
  end;
  if FileExists(@'Admin/upload.prg') then
    Write(@ahref);
    Write(@prefix);
    Write(@'Admin/upload.prg?base=');
    Write(@pi);
    Write(@img);
    Write(@folder);
    Write(@border);
    Write(@'Upload File</a>');
    Write(@br);
  end;
  {if FileExists(@'vfs/Admin/mkinfo.prg') then
    Write(@ahref);
    Write(@prefix);
    Write(@'Admin/mkinfo.prg?base=');
    Write(@pi);
    Write(@img);
    Write(@folder);
    Write(@border);
    Write(@'Create Metadata</a>');
    Write(@br);
  end;}
  Exit;
end.

