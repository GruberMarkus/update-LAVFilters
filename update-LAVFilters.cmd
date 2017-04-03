@echo off
pushd "%~dp0"
isadmin.exe -q
if %errorlevel% neq 1 (
	echo Script needs admin rights, which were not provided.
	exit /b 1
)


cls
echo Preparations
echo ----------------------------------------
Call :Cleaning
Call :GetLAVPath
echo Done.

echo.
echo.
echo Get LAVFilters nightly builds
echo ----------------------------------------
setlocal ENABLEDELAYEDEXPANSION
set tempLAVNightlyVersion=0000000000000000
FOR /F "tokens=3 delims= " %%a IN ('wget.exe --spider -r -l 2 -nd --no-parent -A exe https://files.1f0.de/lavf/nightly 2^>^&1 ^| findstr /R /I /C:"https://.*.exe"') DO (
	set tempLAVVersionA=0000
	set tempLAVVersionB=0000
	set tempLAVVersionC=0000
	set tempLAVVersionD=0000

	REM Parse root folder
	FOR /F "tokens=5 delims=/" %%b IN ("%%a") do (
		set tempLAVNightlyVersionTemp=%%b
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:"=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:-Installer.exe=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:LAVFilters-=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:.exe=!
		for /f "tokens=1 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionA=0000%%x
		SET tempLAVVersionA=!tempLAVVersionA:~-4!
		for /f "tokens=2 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionB=0000%%x
		SET tempLAVVersionB=!tempLAVVersionB:~-4!
		for /f "tokens=3 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionC=0000%%x
		SET tempLAVVersionC=!tempLAVVersionC:~-4!
		for /f "tokens=4 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionD=0000%%x
		SET tempLAVVersionD=!tempLAVVersionD:~-4!
		set tempLAVNightlyVersionTemp=!tempLAVVersionA!!tempLAVVersionB!!tempLAVVersionC!!tempLAVVersionD!
		if !tempLAVNightlyVersionTemp! gtr !tempLAVNightlyVersion! (
			set tempLAVNightlyVersion=!tempLAVNightlyVersionTemp!
			set tempLAVNightlyURL=%%a
		)
	)

	REM Parse first level of child folders
	FOR /F "tokens=6 delims=/" %%b IN ("%%a") do (
		set tempLAVNightlyVersionTemp=%%b
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:"=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:-Installer.exe=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:LAVFilters-=!
		set tempLAVNightlyVersionTemp=!tempLAVNightlyVersionTemp:.exe=!
		for /f "tokens=1 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionA=0000%%x
		SET tempLAVVersionA=!tempLAVVersionA:~-4!
		for /f "tokens=2 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionB=0000%%x
		SET tempLAVVersionB=!tempLAVVersionB:~-4!
		for /f "tokens=3 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionC=0000%%x
		SET tempLAVVersionC=!tempLAVVersionC:~-4!
		for /f "tokens=4 delims=.-" %%x in ("!tempLAVNightlyVersionTemp!") do set tempLAVVersionD=0000%%x
		SET tempLAVVersionD=!tempLAVVersionD:~-4!
		set tempLAVNightlyVersionTemp=!tempLAVVersionA!!tempLAVVersionB!!tempLAVVersionC!!tempLAVVersionD!
		if !tempLAVNightlyVersionTemp! gtr !tempLAVNightlyVersion! (
			set tempLAVNightlyVersion=!tempLAVNightlyVersionTemp!
			set tempLAVNightlyURL=%%a
		)
	)
)
setlocal DISABLEDELAYEDEXPANSION
echo Latest version found: %tempLAVNightlyVersion:~0,4%.%tempLAVNightlyVersion:~4,4%.%tempLAVNightlyVersion:~8,4%.%tempLAVNightlyVersion:~12,4%
echo %tempLAVNightlyURL%
if "%tempLAVNightlyVersion%"=="" (
	echo Error getting latest LAV nightly builds - exiting.
	goto :end
)

echo.
echo.
echo Get latest LAVFilters stable build
echo ----------------------------------------
FOR /F "tokens=2 delims= " %%a IN ('wget.exe -q -O- https://api.github.com/repos/nevcairiel/lavfilters/releases/latest ^| findstr /r /i /c:"browser_download_url.*installer.exe.*"') DO (
	set tempLAVStableURL=%%a
	FOR /F "tokens=8 delims=/" %%b IN ("%%a") DO set tempLAVStableVersion=%%b
)
set tempLAVStableURL=%tempLAVStableURL:"=%

set tempLAVStableVersion=%tempLAVStableVersion:"=%
set tempLAVStableVersion=%tempLAVStableVersion:-Installer.exe=%
set tempLAVStableVersion=%tempLAVStableVersion:LAVFilters-=%
set tempLAVStableVersion=%tempLAVStableVersion:.exe=%
set tempLAVVersionA=0000
set tempLAVVersionB=0000
set tempLAVVersionC=0000
set tempLAVVersionD=0000
for /f "tokens=1 delims=.-" %%a in ("%tempLAVStableVersion%") do set tempLAVVersionA=0000%%a
SET tempLAVVersionA=%tempLAVVersionA:~-4%
for /f "tokens=2 delims=.-" %%a in ("%tempLAVStableVersion%") do set tempLAVVersionB=0000%%a
SET tempLAVVersionB=%tempLAVVersionB:~-4%
for /f "tokens=3 delims=.-" %%a in ("%tempLAVStableVersion%") do set tempLAVVersionC=0000%%a
SET tempLAVVersionC=%tempLAVVersionC:~-4%
for /f "tokens=4 delims=.-" %%a in ("%tempLAVStableVersion%") do set tempLAVVersionD=0000%%a
SET tempLAVVersionD=%tempLAVVersionD:~-4%
set tempLAVStableVersion=%tempLAVVersionA%%tempLAVVersionB%%tempLAVVersionC%%tempLAVVersionD%
echo Latest version found: %tempLAVStableVersion:~0,4%.%tempLAVStableVersion:~4,4%.%tempLAVStableVersion:~8,4%.%tempLAVStableVersion:~12,4%
echo %tempLAVStableURL%

if "%tempLAVStableVersion%"=="" (
	echo Error getting latest LAV official build - exiting.
	goto :end
)


echo.
echo.
echo Compare
echo ----------------------------------------
FOR /F "tokens=2*" %%A IN ('reg.exe query "hklm\software\wow6432node\microsoft\windows\currentversion\uninstall\lavfilters_is1" /v "DisplayVersion" 2^>NUL ^| FIND "REG_SZ"') DO SET tempLAVInstalledVersion=%%B
set tempLAVVersionA=0000
set tempLAVVersionB=0000
set tempLAVVersionC=0000
set tempLAVVersionD=0000
for /f "tokens=1 delims=.-" %%a in ("%tempLAVInstalledVersion%") do set tempLAVVersionA=0000%%a
SET tempLAVVersionA=%tempLAVVersionA:~-4%
for /f "tokens=2 delims=.-" %%a in ("%tempLAVInstalledVersion%") do set tempLAVVersionB=0000%%a
SET tempLAVVersionB=%tempLAVVersionB:~-4%
for /f "tokens=3 delims=.-" %%a in ("%tempLAVInstalledVersion%") do set tempLAVVersionC=0000%%a
SET tempLAVVersionC=%tempLAVVersionC:~-4%
for /f "tokens=4 delims=.-" %%a in ("%tempLAVInstalledVersion%") do set tempLAVVersionD=0000%%a
SET tempLAVVersionD=%tempLAVVersionD:~-4%
set tempLAVInstalledVersion=%tempLAVVersionA%%tempLAVVersionB%%tempLAVVersionC%%tempLAVVersionD%

set tempLAVLatestVersionFound=%tempLAVStableVersion%
set tempLAVLatestVersionURL=%tempLAVStableURL%
If %tempLAVNightlyVersion% gtr %tempLAVStableVersion% (
	set tempLAVLatestVersionFound=%tempLAVNightlyVersion%
	set tempLAVLatestVersionURL=%tempLAVNightlyURL%
)

echo Currently installed:    %tempLAVInstalledVersion:~0,4%.%tempLAVInstalledVersion:~4,4%.%tempLAVInstalledVersion:~8,4%.%tempLAVInstalledVersion:~12,4%
echo Latest stable version:  %tempLAVStableVersion:~0,4%.%tempLAVStableVersion:~4,4%.%tempLAVStableVersion:~8,4%.%tempLAVStableVersion:~12,4%
echo Latest nightly version: %tempLAVNightlyVersion:~0,4%.%tempLAVNightlyVersion:~4,4%.%tempLAVNightlyVersion:~8,4%.%tempLAVNightlyVersion:~12,4%
if "%tempLAVLatestVersionFound%"=="%tempLAVInstalledVersion%" (
	echo.
	echo Last installed LAV version matches most current available version.
	echo Nothing to do.
	goto :end
)
echo Version to install:     %tempLAVLatestVersionFound:~0,4%.%tempLAVLatestVersionFound:~4,4%.%tempLAVLatestVersionFound:~8,4%.%tempLAVLatestVersionFound:~12,4%


echo.
echo.
echo Download latest build
echo ----------------------------------------
if defined tempLAVInstallPath (
	for /F "tokens=*" %%A in ('handle.exe /accepteula /nobanner "%tempLAVInstallPath%" 2^>^&1 ^| findstr /I "%tempLAVInstallPath%"') do (
		echo LAVFilters are in use, new version can not be installed.
		goto :end
	)
)
echo Downloading %tempLAVLatestVersionURL%.
wget.exe -q --show-progress --progress=bar:force:noscroll --output-document="%temp%\tempLAVlav.exe" %tempLAVLatestVersionURL%


echo.
echo.
echo Install latest build
echo ----------------------------------------
if defined tempLAVInstallPath (
	for /F "tokens=*" %%A in ('handle.exe /accepteula /nobanner "%tempLAVInstallPath%" 2^>^&1 ^| findstr /I "%tempLAVInstallPath%"') do (
		echo LAVFilters are in use, new version can not be installed.
		goto :end
	)
)

echo Full install, keep settings, no system restart
echo Applications are not closed or tried to be restarted
echo.
"%temp%\tempLAVlav.exe" /silent /norestart /nocloseapplications /norestartapplications /type=full

if %errorlevel% neq 0 (
	echo Installation failed with an error.
) else (
	echo No error during installation.
)


:end
echo.
echo.
echo Cleaning up
echo ----------------------------------------
call :Cleaning
echo Done.
goto :eof


:Cleaning
if exist "%temp%\tempLAVlav.exe" del /f /q "%temp%\tempLAVlav.exe"
set tempLAVInstalledVersion=
set tempLAVLatestVersionFound=
set tempLAVLatestVersionURL=
set tempLAVStableVersion=
set tempLAVStableURL=
set tempLAVNightlyVersion=
set tempLAVNightlyVersionTemp=
set tempLAVNightlyURL=
set tempLAVVersionA=
set tempLAVVersionB=
set tempLAVVersionC=
set tempLAVVersionD=
set tempLAVInstallPath=
goto :eof


:GetLAVPath
FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKLM\software\wow6432node\microsoft\windows\currentversion\uninstall\lavfilters_is1" /v "inno setup: app path"') DO SET tempLAVInstallPath=%%B
if not defined tempLAVInstallPath (
	FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKCU\software\wow6432node\microsoft\windows\currentversion\uninstall\lavfilters_is1" /v "inno setup: app path"') DO SET tempLAVInstallPath=%%B
	if not defined tempLAVInstallPath (
		FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKLM\software\microsoft\windows\currentversion\uninstall\lavfilters_is1" /v "inno setup: app path"') DO SET tempLAVInstallPath=%%B
		if not defined tempLAVInstallPath (
				FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKCU\software\microsoft\windows\currentversion\uninstall\lavfilters_is1" /v "inno setup: app path"') DO SET tempLAVInstallPath=%%B
				rem if not defined tempLAVInstallPath (
				rem 	set tempLAVInstallPath="C:\Program Files (x86)\LAV Filters"
				rem )
		)
	)
)
goto :eof
