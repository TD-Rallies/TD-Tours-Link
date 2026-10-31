@echo off
setlocal

rem TOUR localhost launcher
rem Preferred browser: Chrome
rem Fallback browser: Edge
rem Expected location: same folder as index.html and Run_TOUR_Localhost.ps1.

set "BASE=%~dp0"
set "INDEX=%BASE%index.html"
set "SERVER=%BASE%Run_TOUR_Localhost.ps1"
set "PORT=8766"
set "URL=http://127.0.0.1:%PORT%/index.html"

if not exist "%INDEX%" (
  echo TOUR launcher could not find:
  echo "%INDEX%"
  echo.
  echo Check that this launcher is in the same folder as index.html.
  echo Press any key to continue . . .
  pause >nul
  exit /b 1
)

if not exist "%SERVER%" (
  echo TOUR launcher could not find:
  echo "%SERVER%"
  echo.
  echo Check that Run_TOUR_Localhost.ps1 is beside this launcher.
  echo Press any key to continue . . .
  pause >nul
  exit /b 1
)

rem Start the localhost server hidden. If it is already running, the new
rem server process exits harmlessly and the existing server is reused.
start "" /min powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%SERVER%" -Port %PORT%

rem Give localhost a moment to start before opening the app.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$u='http://127.0.0.1:%PORT%/__tour_health'; for($i=0;$i -lt 30;$i++){try{$r=Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 1; if($r.StatusCode -eq 200){exit 0}}catch{}; Start-Sleep -Milliseconds 100}; exit 1" >nul 2>nul

if errorlevel 1 (
  echo TOUR localhost server did not start on port %PORT%.
  echo.
  echo Close any old TOUR/local server window or restart Windows, then try again.
  echo Press any key to continue . . .
  pause >nul
  exit /b 1
)

set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
set "PROFILE=%BASE%.profile-chrome-tour"
if exist "%BROWSER%" goto launch
set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
set "PROFILE=%BASE%.profile-chrome-tour"
if exist "%BROWSER%" goto launch
set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
set "PROFILE=%BASE%.profile-edge-tour"
if exist "%BROWSER%" goto launch
set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
set "PROFILE=%BASE%.profile-edge-tour"
if exist "%BROWSER%" goto launch
where msedge >nul 2>nul
if %errorlevel%==0 (
  set "BROWSER=msedge"
  set "PROFILE=%BASE%.profile-edge-tour"
  goto launch
)

echo TOUR could not find Chrome or Edge.
echo.
echo Please install Google Chrome or Microsoft Edge, then try again.
echo Press any key to continue . . .
pause >nul
exit /b 1

:launch
start "" "%BROWSER%" --app="%URL%" --user-data-dir="%PROFILE%" --window-size=1600,980 --window-position=40,40
exit /b 0
