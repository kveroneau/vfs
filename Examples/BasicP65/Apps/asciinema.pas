////////////////////////////////////////////
// New program created in 27-10-23}
////////////////////////////////////////////
program asciinema;

uses vfs6502;

var
  fi: array[60] of char;

procedure RunPlayer;
begin
  if isNull(@fi) then
    WriteLn(@'Please specify a movie file to open.');
    EndRequest;
  end; 
  WriteLn(@'<div id="termplayer" style="align: center;"></div>');
  WriteLn(@'<script src="/tests/asciinema-player.min.js"></script>');
  WriteLn(@'<script>AsciinemaPlayer.create('#39'/tests/demo.cast'#39', document.getElementById('#39'termplayer'#39'));</script>');
  EndRequest;
end; 

begin
  SITE_HEADER:=@'<link rel="stylesheet" type="text/css" href="/tests/asciinema-player.css"/>';
  PAGE_TITLE:=@'Asciinema Player';
  GetContent:=@RunPlayer;
  value:=@fi;
  GetQuery(@'file');
  Exit;
end.

