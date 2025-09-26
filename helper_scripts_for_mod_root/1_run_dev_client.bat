@echo off
setlocal ENABLEDELAYEDEXPANSION
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Stopping old Gradle daemons...
call gradlew --stop
echo Running dev client with Gradle...
call gradlew --no-daemon runClient
endlocal
