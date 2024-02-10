////////////////////////////////////////////
// New program created in 4-6-23}
////////////////////////////////////////////
program adddir;

uses vfs6502;

procedure mkdir(s: pointer absolute $40);
begin
  asm 
	  LDY #$a
    JSR $ffc0 
  end; 
end; 

procedure HandleRequest;
begin
  if not IsSession(@'login', ADMIN_PASS) then
    WriteLn(@'You are not suppose to be here...');
    EndRequest;    
  end; 
  Write(@'<h3>Add-dir.prg</h3><hr width="300" align="left">');
  value:=$400;
  GetPost(@'dir');
  if not isNull(value) then
    mkdir(value);
    Write(@'<a href="');
    Write(value);
    WriteLn(@'">Go to directory...</a>');
    EndRequest;
  end; 
  GetQuery(@'base');
  WriteLn(@'<form action="add-dir.prg" method="post">');
  Write(@'Directory: <input type="text" name="dir" value="');
  Write(value);
  WriteLn(@'"><br/>');
  WriteLn(@'<input type="submit" name="addit" value="Add Directory"/>');
  WriteLn(@'</form>');
  EndRequest;
end;

begin
  GetContent:=@HandleRequest;
  PAGE_TITLE:=@'Create Directory';
  Exit;
end. 

