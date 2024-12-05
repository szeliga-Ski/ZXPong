; build for Garcia book

cls
rem "D:/Users/Mark/Retro Stuff/ZX Spectrum/06 - Development/Assemblers/pasmo-0.5.5/pasmo.exe" --name ZX-Pong --tapbas main.asm Pong.tap --Pong.log
rem "D:/Users/Mark/Retro Stuff/ZX Spectrum/06 - Development/Assemblers/pasmo-0.5.5/pasmo.exe" --name ZX-Pong --tap main.asm pong.tap

"c:/Users/szeli/OneDrive/Retro Stuff/ZX Spectrum/06 - Development/Assemblers/pasmo-0.5.5/pasmo.exe" --name ZX-Pong --tap main.asm pong.tap
copy /b PongLoader.tap+PongScr.tap+pong.tap ZX-Pong.tap