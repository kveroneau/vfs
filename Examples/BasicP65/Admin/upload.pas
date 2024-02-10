////////////////////////////////////////////
// New program created in 4-6-23}
////////////////////////////////////////////
program upload;

uses vfs6502;

procedure HandleRequest;
var
  buf: array[60] of char;
begin
  if not IsSession(@'login', ADMIN_PASS) then
    WriteLn(@'You are not suppose to be here...');
    Exit;    
  end; 
  Write(@'<h3>Upload.app</h3><hr width="300" align="left"/>');
  value:=@buf;
  GetPost(@'addit');
  if not isNull(@buf) then
    GetPost(@'dir');
    UploadFile(@buf);
    WriteLn(@'File uploaded successfully.');
    Write(@'<a href="');
    Write(value);
    WriteLn(@'">View file...</a>');
    Exit;
  end; 
  Write(@'<form enctype="multipart/form-data" action="upload.prg" method="post">');
  Write(@'Upload as: <input type="text" name="dir" value="');
  GetQuery(@'base');
  Write(value);
  WriteLn(@'"/><br/>');
  WriteLn(@'Filename: <input type="file" name="fi"/><br/>');
  Write(@'<input type="submit" name="addit" value="Upload file"/>');
  WriteLn(@'</form>');
  Exit;
end;

begin
  GetContent:=@HandleRequest;
  PAGE_TITLE:=@'Upload.prg';
  Exit;
end. 

