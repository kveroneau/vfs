////////////////////////////////////////////
// New program created in 5-6-23}
////////////////////////////////////////////
{$OUTPUTHEX 'debug.eXe'}
{$SET_DATA_ADDR '6000-65FF'}
program debug;

uses vfs6502;
{$ORG $2000}

type
  str20 = array[20] of char;
  pstr20 = ^str20;

var
  br: array of char = '<br/>';
  dash: array of char = ' - ';

procedure HandleRequest;
var
  p: pstr20;
  LOAD_ADDR: pointer absolute $60;
  pcallkey: pointer absolute $90;
  p1,p2,v: pointer;  

  mysize: word;
  fbuf: array[1024] of byte;
begin
  p1:=param1;
  p2:=param2;
  v:=value;
  WriteLn(@'<pre>Basic debug program.');
  value:=@fbuf;
  GetPathInfo;
  Write(@'VFS PathInfo: ');
  WriteLn(@fbuf);
  Write(@'6502 Run Count: ');
  WriteWord(RUN_COUNT);
  Write(@'<br/>Load Address for last PRG: ');
  WriteHex(LOAD_ADDR);
  Write(@'<br/>Parameter 1: ');
  WriteHex(p1);
  Write(@dash);
  WriteLn(p1);
  Write(@'Parameter 2: ');
  WriteHex(p2);
  Write(@dash);
  WriteLn(p2);
  Write(@'Value: ');
  WriteHex(v);
  Write(@dash);
  WriteLn(v);
  {Write(@'Current Creds: ');
  value:=$400;
  GetSession(@'login');
  WriteLn(value);}
  Write(@'Site Title: ');
  WriteLn(SITE_TITLE);
  Write(@'Site Template: ');
  WriteLn(TMPL);
  Write(@'Page Title: ');
  WriteLn(PAGE_TITLE);
  Write(@'Admin Pass: ');
  WriteHex(ADMIN_PASS);
  Write(@'<br/>Folder Vector: ');
  WriteHex(FOLDER_VEC);
  Write(@'<br/>Admin Vector: ');
  WriteHex(ADMIN_VEC);
  Write(@'<br/>Shell Vector: ');
  WriteHex(SHELL_VEC);
  Write(@'<br/>CALL Key: ');
  WriteHex(pcallkey);
  WriteLn(@'</pre>');
  WriteLn(@dash);
  EndRequest;
  if IsSession(@'login', ADMIN_PASS) then
    Write(@'<br/>FRC Pass: ');
    WriteLn(@FRC_PASS);
    Write(@'FRC Header: ');
    WriteLn(@FRC_HDR);
    Write(@'FRC Button: ');
    WriteLn(@FRC_BTN);
    Write(@'FRC Hidden: ');
    if FRC_HIDE then
      WriteLn(@'Yes');
    else
      WriteLn(@'No');
    end; 
    if IsQuery(@'reboot', @'true') then
      asm JMP $FA00 end;
    end;
    WriteLn(@'<br/><a href="?reboot=true">Reboot...</a>');
  else
    WriteLn(@'<br/>Log in to do more!');
  end;
  mysize:=LoadFile(@'vfs/tests/debug.prg', @fbuf);
  Write(@'My File size: ');
  WriteHex(mysize);
  {fbuf[mysize]:=$0;
  Write(@'<pre>');
  Write(@fbuf);
  Write(@'</pre>');}
  EndRequest;
end;

begin
  GetContent:=@HandleRequest;
  PAGE_TITLE:=@'Debug program';
  Exit;
end. 
