////////////////////////////////////////////
// New program created in 5-6-23}
////////////////////////////////////////////
{$BOOTLOADER $20,'COD_HL','JMP',$f0,$ff}
{$ORG $2000}
program mkrc;

uses vfs6502;

type
  str20 = array[20] of char;
  pstr20 = ^str20;

var
  br: array of char = '<br/>';

procedure HandleRequest;
var
  p: pstr20;
  rcfile: array[80] of char;
begin
  if not IsSession(@'login', ADMIN_PASS) then
    WriteLn(@'You are unable to run this program with your current abilities.');
    EndRequest;
  end; 
  value:=@rcfile;
  GetPost(@'rcfile');
  if not isNull(value) then
    Write(@'<pre>Creating RC File: ');
    WriteLn(@rcfile);
    value:=@FRC_PASS;
    GetPost(@'pass');
    Write(@'Password: ');
    WriteLn(@FRC_PASS);
    value:=@FRC_HDR;
    GetPost(@'hdr');
    Write(@'Header: ');
    WriteLn(@FRC_HDR);
    value:=@FRC_BTN;
    GetPost(@'btn');
    Write(@'Button: ');
    WriteLn(@FRC_BTN);
    if IsPost(@'hide', @'true') then
      WriteLn(@'Folder set to hidden.');
      FRC_HIDE:=True;
    else
      FRC_HIDE:=False;
    end;
    value:=@FRC_HOOK;
    GetPost(@'hook');
    Write(@'Hook: ');
    WriteLn(@FRC_HOOK);
    SaveFile(@rcfile, $1a00, Word($66));
    WriteLn(@'RC File created!</pre>');
    EndRequest;
  end; 
  Write(@'<h3>mkrc.prg</h3><hr width="300" align="left">');
  WriteLn(@'<form action="mkrc.prg" method="post">');
  Write(@'RC File: <input type="text" name="rcfile"/>');
  WriteLn(@br);
  Write(@'Password: <input type="password" name="pass"/>');
  WriteLn(@br);
  Write(@'Auth Header: <input type="text" name="hdr"/>');
  WriteLn(@br);
  Write(@'Button Text: <input type="text" name="btn"/>');
  WriteLn(@br);
  Write(@'Hide Folder: <input type="checkbox" name="hide" value="true"/>');
  WriteLn(@br);
  Write(@'Hook: <input type="text" name="hook"/>');
  WriteLn(@br);  
  Write(@'<input type="submit" name="addit" value="Create RC File"/>');
  WriteLn(@br);
  WriteLn(@'</form>');
  EndRequest;
end;

begin
  GetContent:=@HandleRequest;
  PAGE_TITLE:=@'mkrc.prg';
  Exit;
end. 

