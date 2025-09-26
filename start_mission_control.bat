@echo off
set "PY=G:\My Drive\python-3.13.7-embed-amd64\python.exe"
cd /d "%~dp0"
if not exist "%PY%" (
  echo Could not find %PY%
  echo Update the PY path in this file to your Python location on G:
  pause
  exit /b 1
)
echo Starting Mission Control on http://localhost:8000 ...
start "" http://localhost:8000/index.html
"%PY%" -m http.server 8000
pause
