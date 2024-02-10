////////////////////////////////////////////
// New program created in 26-10-23}
////////////////////////////////////////////
{$OUTPUTHEX 'libmarkdown.OVL'}
{$SET_DATA_ADDR 'C000-DFFF'}
program mdsys;

uses vfs6502;
{$ORG $2000}

var
  fi: array[40] of char;
  md: array[4096] of char;
  fsize: word;
  
begin
  value:=@fi;
  GetPathInfo;
  PAGE_TITLE:=@fi;
  Write(@'<div id="markdown">');
  fsize:=LoadFile(@fi, @md);
  md[fsize]:=#0;
  StrCat(@fi, @'.lib');
  if FileExists(@fi) then
    fsize:=LoadFile(@fi, $7000);
    TAG_VEC:=$7000;
    TagParam:=@fi;
  else
    TAG_VEC:=Word(0);
    TagParam:=Word(0);
  end; 
  Write(@md);
  Write(@'</div><script src="/kdocs/marked.min.js"></script>');
  Write(@'<script>document.getElementById('#39'markdown'#39').innerHTML=marked(document.getElementById('#39'markdown'#39').innerHTML);</script>');
  Exit;
end.

