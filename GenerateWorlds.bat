@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF EXIST data\save\region0 (
	ECHO ERROR: region0 folder already present, please rename/move it then try again.
	PAUSE
	EXIT /b
)

FOR /f %%G IN ('find /c "[TITLE:" ^< data\init\world_gen.txt') DO SET gnum=%%G
ECHO There are %gnum% available generator pesets in your world_gen file:
ECHO;
FOR /f "delims=" %%T IN ('find "[TITLE:" ^< data\init\world_gen.txt') DO (
	SET gparam=%%T
	IF %gnum% LEQ 20 (ECHO !gparam:~8,-1!) ELSE (SET _outlist=!_outlist!, !gparam:~8,-1!)
)
IF %gnum% GTR 20 echo %_outlist:~2%
ECHO;
SET /p genparam=Which preset do you want to use?: 
SET /p maxcount=How many worlds to generate?: 
SET /a count=1

:GEN
ECHO;
ECHO Generating World %count%..

"Dwarf Fortress.exe" -gen 0 RANDOM "%genparam%"

IF NOT EXIST data\save\region0 (
	ECHO Something happened, world was not generated! Trying again..
	TIMEOUT 10 /nobreak
	GOTO GEN
)

FOR %%F IN (region0*world_history.txt) DO SET filename=%%~nxF
SET /p worldname=<%filename%
ECHO;
ECHO World name is %worldname%. Organizing files now..
ECHO;
optipng -q -zc9 -zm9 -zs0 -f0 *.bmp
DEL *.bmp
MD data\save\region0\info
MOVE region0* data\save\region0\info
REN "data\save\region0\info\region0-world_gen_param.txt" "%worldname: =%-world_gen_param.txt"

SET "_input=%worldname%"
SET "_output="
SET "map=abcdefghijklmnopqrstuvwxyz"

:CHARFIX
IF NOT DEFINED _input GOTO ENDFIX
FOR /f "delims=*~ eol=*" %%C IN ("!_input:~0,1!") DO (
	IF "!map:%%C=!" NEQ "!map!" SET "_output=!_output!%%C"
)
SET "_input=%_input:~1%"
GOTO CHARFIX
:ENDFIX
SET "worldname=%_output%"

:DUPCHECK
IF EXIST data\save\%worldname% (
	SET worldname=%worldname%_2
	GOTO DUPCHECK
)

REN data\save\region0 %worldname%

IF %count% EQU %maxcount% (
	ECHO;
	ECHO All %count% worlds complete!
	PAUSE
	EXIT /b
)

ECHO;
ECHO World %count% done. Waiting in case user wants to abort..
TIMEOUT 20 /nobreak
SET /a count+=1
GOTO GEN
REM script by Nik
