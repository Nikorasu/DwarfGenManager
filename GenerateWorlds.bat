@ECHO OFF
IF EXIST data\save\region0 (
	ECHO ERROR: region0 folder already present, please rename/move then try again..
	GOTO error
)

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
	GOTO GEN
)

FOR /f %%n IN ('DIR /b region0*world_history.txt') DO SET filename=%%n
SET /p worldname=<%filename%

ECHO World name is %worldname%. Organizing files now..
optipng -q -zc9 -zm9 -zs0 -f0 *.bmp
DEL *.bmp
MD data\save\region0\info
MOVE region0* data\save\region0\info
REN "data\save\region0\info\region0-world_gen_param.txt" "%worldname: =%-world_gen_param.txt"

SETLOCAL EnableDelayedExpansion
SET "_input=!worldname!"
SET "_output="
SET "map=abcdefghijklmnopqrstuvwxyz"
:CHARFIX
IF NOT DEFINED _input GOTO endFIX
FOR /F "delims=*~ eol=*" %%C IN ("!_input:~0,1!") DO (
    IF "!map:%%C=!" NEQ "!map!" SET "_output=!_output!%%C"
)
SET "_input=!_input:~1!"
GOTO CHARFIX
:endFIX
SET "worldname=!_output!"
SETLOCAL DisableDelayedExpansion

:DUPCHECK
IF EXIST data\save\%worldname% (
	SET worldname=%worldname%_2
	GOTO DUPCHECK
)

REN data\save\region0 %worldname%

IF %count%==%maxcount% GOTO :END

ECHO;
ECHO World %count% done. Waiting in case user wants to abort..
TIMEOUT 20 /nobreak

SET /a count+=1
GOTO :GEN

:END
ECHO;
ECHO All worlds complete!
:error
PAUSE
REM script by Nik
