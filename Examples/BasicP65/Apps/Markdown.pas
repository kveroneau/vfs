////////////////////////////////////////////
// New program created in 11-6-23}
////////////////////////////////////////////
{$SET_DATA_ADDR 'C000-DFFF'}
program Markdown;

uses vfs6502;

var
  fi: array[60] of char;
  md: array[4096] of char;
  fsize: word;

procedure HandleTag;
begin
  
end; 

begin
  value:=@fi;
  GetQuery(@'file');
  if fi[0] = #0 then
    Write(@'No Markdown file selected as input.');
    Exit;
  end;
  PAGE_TITLE:=@fi;
  if IsSession(@'login', ADMIN_PASS) then
    Write(@'<a href="');
    Write(@fi);
    Write(@'?edit=y">Edit</a><hr/>');
  end; 
  Write(@'<div id="markdown">');
  fsize:=LoadFile(@fi, @md);
  {ESaveFile(@'/vfs/tests/testfile',@md ,fsize);}
  md[fsize]:=#0;
  TAG_VEC:=@HandleTag;
  TagParam:=@fi;
  WriteTemplate(@md);
  Write(@'</div><script src="/kdocs/marked.min.js"></script>');
  Write(@'<script>document.getElementById('#39'markdown'#39').innerHTML=marked(document.getElementById('#39'markdown'#39').innerHTML);</script>');
  Exit;
end.

