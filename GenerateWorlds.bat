@ECHO OFF
TITLE Generation Manager  - by Nik

IF NOT EXIST "Dwarf Fortress.exe" (
	ECHO ERROR: "Dwarf Fortress.exe" not found, place script into same folder.
	PAUSE && EXIT /b
)
IF EXIST data\save\region0 (
	ECHO ERROR: region0 folder already present, rename/move it then try again.
	PAUSE && EXIT /b
)

SETLOCAL EnableDelayedExpansion

FOR /f %%G IN ('find /c "[TITLE:" ^< data\init\world_gen.txt') DO SET gnum=%%G
ECHO There are %gnum% available generator pesets in your world_gen file:
ECHO,
FOR /f "delims=" %%T IN ('find "[TITLE:" ^< data\init\world_gen.txt') DO (
	SET gparam=%%T
	IF %gnum% LEQ 20 (ECHO !gparam:~8,-1!) ELSE (SET outlist=!outlist!, !gparam:~8,-1!)
)
IF %gnum% GTR 20 ECHO %outlist:~2%
ECHO,

SET /p genparam=Which preset do you want to use?: 
SET /p maxcount=How many worlds to generate?: 
SET /a wcount=1
SET logfile=GenLog_%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%.txt
SET logfile=%logfile: =%

:GEN
ECHO, && ECHO,
ECHO Generating World %wcount%..

"Dwarf Fortress.exe" -gen 0 RANDOM "%genparam%"

IF NOT EXIST data\save\region0 (
	ECHO Something happened, world was not generated! Trying again..
	TIMEOUT 10 /nobreak
	GOTO GEN
)
IF NOT EXIST region0*world_history.txt (
	ECHO Somehow info files failed, renaming world and moving on..
	optipng -q -zc9 -zm9 -zs0 -f0 region0*.bmp && DEL region0*.bmp
	MD data\save\region0\info
	MOVE region0* data\save\region0\info
	REN data\save\region0 world%wcount%_noinfo
	ECHO World %wcount% info files not found.>>%logfile%
	ECHO,>>%logfile%&&ECHO,>>%logfile%
	GOTO SKIPINFO
)

FOR %%F IN (region0*world_history.txt) DO SET histfile=%%~nxF
SET /p worldname=<%histfile%
ECHO,
ECHO World name is %worldname%. Organizing files now..
ECHO,
optipng -q -zc9 -zm9 -zs0 -f0 region0*.bmp && DEL region0*.bmp
MD data\save\region0\info
MOVE region0* data\save\region0\info
REN "data\save\region0\info\region0-world_gen_param.txt" "%worldname: =%-world_gen_param.txt"

SET charin=%worldname%
SET charout=
SET map=abcdefghijklmnopqrstuvwxyz

:CHARFIX
IF NOT DEFINED charin GOTO ENDFIX
FOR /f "delims=*~ eol=*" %%C IN ("!charin:~0,1!") DO (
	IF "!map:%%C=!" NEQ "!map!" SET charout=!charout!%%C
)
SET charin=%charin:~1%
GOTO CHARFIX
:ENDFIX
SET worldname=%charout%

:DUPCHECK
IF EXIST data\save\%worldname% (
	SET worldname=%worldname%_2
	GOTO DUPCHECK
)

ECHO %worldname%  %histfile:~8,5%>>%logfile%
ECHO,>>%logfile%
FOR %%P IN (data\save\region0\info\region0*world_sites_and_pops.txt) DO SET popfile=%%~fsP
FOR /f %%L IN ('find " Dwarves" ^< %popfile%') DO SET lPop=         %%L
IF NOT DEFINED lPop SET lPop=         0
ECHO Dwarves: %lPop:~-9% >> %logfile%&& SET lPop=
FOR /f %%L IN ('find " Goblins" ^< %popfile%') DO SET lPop=         %%L
IF NOT DEFINED lPop SET lPop=         0
ECHO Goblins: %lPop:~-9% >> %logfile%&& SET lPop=
FOR /f %%L IN ('find " Elves" ^< %popfile%') DO SET lPop=         %%L
IF NOT DEFINED lPop SET lPop=         0
ECHO Elves:   %lPop:~-9% >> %logfile%&& SET lPop=
FOR /f %%L IN ('find " Humans" ^< %popfile%') DO SET lPop=         %%L
IF NOT DEFINED lPop SET lPop=         0
ECHO Humans:  %lPop:~-9% >> %logfile%&& SET lPop=
FOR /f %%L IN ('find " Kobolds" ^< %popfile%') DO SET lPop=         %%L
IF NOT DEFINED lPop SET lPop=         0
ECHO Kobolds: %lPop:~-9% >> %logfile%&& SET lPop=
FOR /f %%L IN ('find /c ", tower" ^< %popfile%') DO SET tCount=         %%L
ECHO Towers:  %tCount:~-9% >> %logfile%
FOR /f "delims=" %%L IN ('find "Total: " ^< %popfile%') DO SET tcPop=%%L
SET tcPop=         %tcPop:~8%
ECHO TotalPop:%tcPop:~-9% >> %logfile%
ECHO,>>%logfile%&&ECHO,>>%logfile%

REN data\save\region0 %worldname%

:SKIPINFO
IF %wcount% EQU %maxcount% (
	ECHO, && ECHO,
	ECHO All %wcount% worlds complete. Summary saved to: %logfile%
	ECHO,
	PAUSE && EXIT /b
)

ECHO,
ECHO World %wcount% done. Waiting in case user wants to abort..
TIMEOUT 20 /nobreak
SET /a wcount+=1
GOTO GEN

REM script by Nik - https://github.com/Nikorasu/DwarfGenManager
