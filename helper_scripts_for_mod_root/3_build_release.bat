@echo off
setlocal
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
call gradlew --stop
call gradlew clean build
echo If successful, your JAR is in .\build\libs\
endlocal
