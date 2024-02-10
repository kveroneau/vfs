////////////////////////////////////////////
// New program created in 14-12-23}
////////////////////////////////////////////
program dumpcore;

uses vfs6502;
{$ORG $FEE0}
  
begin
  DumpState(@'/core.dump');
  WriteLn(@'Core has been dumped.');
  Exit;
end.

