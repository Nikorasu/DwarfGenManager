@ECHO OFF

SET /p genparam=Enter generation parameter title: 
SET /p maxcount=How many worlds to generate?: 
SET /a count=1

:GEN
ECHO;
ECHO Generating World %count%..

"Dwarf Fortress.exe" -gen 0 RANDOM %genparam%

IF NOT EXIST data\save\region0 (
	ECHO Something happened, world was not generated! Trying again..
	TIMEOUT 10 /nobreak
	GOTO :GEN
)

FOR /f %%n IN ('DIR /b region0*world_history.txt') DO SET filename=%%n
SET /p worldname=<%filename%
SET worldname=%worldname: =%

:CHECK
IF EXIST data\save\%worldname% (
	SET worldname=%worldname%_2
	GOTO :CHECK
)

ECHO World name is %worldname%. Organizing files now..
optipng -q -zc9 -zm9 -zs0 -f0 *.bmp
DEL *.bmp
MD data\save\region0\info
MOVE region0* data\save\region0\info
REN data\save\region0\info\region0-world_gen_param.txt %worldname%-world_gen_param.txt
REN data\save\region0 %worldname%

IF %count%==%maxcount% GOTO :END

ECHO;
ECHO World %count% done. Waiting in case user wants to abort..
TIMEOUT 30 /nobreak

SET /a count+=1
GOTO :GEN

:END
ECHO;
ECHO All worlds complete!
PAUSE
REM script by Nik
