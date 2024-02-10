////////////////////////////////////////////
// New program created in 4-6-23}
////////////////////////////////////////////
{$BOOTLOADER $20,'COD_HL','JMP',$f0,$ff}
{$ORG $0801}
program logout;

uses stdio;

begin
  asm 
	  LDY #$32
    JSR $ffe0 
  end; 
  WriteLn(@'You have been logged out.');
  Exit;
end.

