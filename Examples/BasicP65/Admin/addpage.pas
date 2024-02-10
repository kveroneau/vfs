////////////////////////////////////////////
// New program created in 4-6-23}
////////////////////////////////////////////
program addpage;

uses vfs6502;

procedure HandleRequest;
var
  buf: array[20] of char;
begin
  if not IsSession(@'login', ADMIN_PASS) then
    WriteLn(@'You are not suppose to be here...');
    Exit;    
  end; 
  Write(@'<h3>Addpage.app</h3><hr width="300" align="left"/>');
  buf[0]:=#0;
  value:=@buf;
  GetPost(@'addit');
  if not isNull(@buf) then
    GetPost(@'fi');
    WriteFile(@buf, @'body');
    WriteLn(@'File Created!');
    Write(@'<a href="');
    Write(@buf);
    WriteLn(@'">View file...</a>');
    Exit;
  end; 
  WriteLn(@'<form action="addpage.prg" method="post">');
  Write(@'Filename: <input type="text" name="fi" value="');
  GetQuery(@'base');
  Write(@buf);
  WriteLn(@'"><br/>');
  WriteLn(@'Contents: <textarea id="body" name="body" rows="25" cols="80"></textarea><br/>');
  WriteLn(@'<input type="submit" name="addit" value="Add Page"/>');
  WriteLn(@'</form>');
  {Write(@'<script src="/iui/tinymce.min.js"></script>');
  Write(@'<script> tinymce.init({selector:"#body"); </script>');}
  EndRequest;
end;

begin
  GetContent:=@HandleRequest;
  PAGE_TITLE:=@'addpage.prg';
  Exit;
end.

