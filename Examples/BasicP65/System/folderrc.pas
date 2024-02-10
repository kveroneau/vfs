////////////////////////////////////////////
// New program created in 17-6-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'F300-F3FF'}
{$OUTPUTHEX 'FolderRC.OVL'}
program folderrc;

uses vfs6502;
{$ORG $F400}

var
  pathinfo: array[60] of char;
  path: array[60] of char;
  FOLDERC_VER: byte = 1;

begin
  PAGE_TITLE:=@'FolderRC';
  if FRC_HOOK[0] <> #0 then
    {Write(@'Hook Exists: ');
    WriteLn(@FRC_HOOK);
    LoadFile(@FRC_HOOK, $2000);
    asm JMP $2000 end;}
    path[0]:=#0;
    StrCat(@path, @FRC_HOOK);
    StrCat(@path, @'?Dir=');
    value:=@pathinfo;
    GetPathInfo;
    StrCat(@path, @pathinfo);
    REDIRECT:=@path;
    Exit;
  end; 
  if FRC_PASS[0] = #0 then
    Exit;
  end;
  if IsSession(@'login', @FRC_PASS) then
    Exit;
  end;
  if IsPost(@'pass', @FRC_PASS) then
    SetSession(@'login', @FRC_PASS);
    Exit;
  end; 
  LogVersion(Word(FOLDERC_VER));
  Write(@'<h1>');
  Write(@FRC_HDR);
  Write(@'</h1><form action="');
  value:=@pathinfo;
  GetPathInfo;
  Write(value);
  Write(@'" method="post">');
  Write(@'Password: <input type="password" name="pass"/>');
  Write(@'<input type="submit" value="');
  Write(@FRC_BTN);
  Write(@'"/></form>');
  Exit;
end.

