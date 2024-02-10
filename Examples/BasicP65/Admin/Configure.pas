////////////////////////////////////////////
// New program created in 5-6-23}
////////////////////////////////////////////
{$SET_DATA_ADDR '6000-6FFF'}
program Configure;

uses vfs6502;
{$ORG $7e00}

type
  str20 = array[20] of char;
  pstr20 = ^str20;

var
  p: pstr20;

  closetag: array of char = '"/><br/>';
  PTitle: array of char = 'title';
  PPass: array of char = 'pass';
  PTmpl: array of char = 'tmpl';
  
  configtitle: array[40] of char;
  configpass: array[20] of char;
  configtmpl: array[60] of char;

procedure EnsureAdmin;
begin
  if not IsSession(@'login', ADMIN_PASS) then
    WriteLn(@'Now... How did you manage to find this program?');
    EndRequest;
  end;   
end; 
  
procedure SaveConfig;
begin
  EnsureAdmin;
  if not IsPost(@PTitle, SITE_TITLE) then
    SITE_TITLE:=@configtitle;
    value:=SITE_TITLE;
    GetPost(@PTitle);
  end; 
  if not IsPost(@PPass, ADMIN_PASS) then
    ADMIN_PASS:=@configpass;
    value:=ADMIN_PASS;
    GetPost(@PPass);
  end; 
  if not IsPost(@PTmpl, TMPL) then
    TMPL:=@configtmpl;
    value:=TMPL;
    GetPost(@PTmpl);
  end; 
  WriteLn(@'All configured.');
  EndRequest;  
end; 

procedure ConfigApp;
begin
  EnsureAdmin;
  Write(@'<h3>Configure.prg</h3><hr width="300" align="left"/>');
  Write(@'<form action="Configure.prg" method="post">');
  Write(@'Site Title: <input type="text" name="title" value="');
  Write(SITE_TITLE);
  WriteLn(@closetag);
  Write(@'Admin Pass: <input type="text" name="pass" value="');
  Write(ADMIN_PASS);
  WriteLn(@closetag);
  Write(@'Template: <input type="text" name="tmpl" value="');
  Write(TMPL);
  WriteLn(@closetag);
  Write(@'<input type="submit" name="doit" value="Save"/></form>');
  EndRequest;
end;

begin
  PAGE_TITLE:=@'Configure.prg';
  if IsPost(@'doit', @'Save') then
    GetContent:=@SaveConfig;
  else
    GetContent:=@ConfigApp;
  end; 
  Exit;
end. 
