////////////////////////////////////////////
// New program created in 17-12-23}
////////////////////////////////////////////
{$SET_DATA_ADDR '5000-6fff'}
program PlayVideo;

uses vfs6502;

type
  str80 = array[80] of char;
  str40 = array[40] of char;

var
  vidfile: str40;
  title: str40;
  ytlink: str40;
  views: word;
  body: array[4096] of char;
  fsize: word;

procedure PlayerHelp;
begin
  WriteLn(@'Please specify a .vid file to open.');
  EndRequest;
end; 

procedure ViewVidFile;
begin
  Write(@'<div style="text-align: center; font-size: 18px;">');
  Write(@title);
  WriteLn(@'</div>');
  Write(@'<center><iframe id="ytplayer" type="text/html" width="640" height="480" src="https://www.youtube.com/embed/');
  Write(@ytlink);
  Write(@'" frameborder="0"></iframe><br/><strong>View count</strong>: ');
  WriteWord(views);
  Write(@'</center><br/><div id="markdown">');
  Write(@body);
  Write(@'</div><script src="/kdocs/marked.min.js"></script>');
  Write(@'<script>document.getElementById('#39'markdown'#39').innerHTML=marked(document.getElementById('#39'markdown'#39').innerHTML);</script>');
  EndRequest;
end; 

begin
  value:=@vidfile;
  GetQuery(@'file');
  if vidfile[0] = #0 then
    PAGE_TITLE:=@'No video file specified';
    GetContent:=@PlayerHelp;
    Exit;
  end;
  PAGE_TITLE:=@vidfile;
  fsize:=LoadFile(@vidfile, @title);
  Inc(views);
  SaveFile(@vidfile, @title, fsize);
  GetContent:=@ViewVidFile;
  Exit;
end.

