:
: mud.bat
:
@echo off
: since this file is located under ./bin go up one level
cd ..

:START

  : starts driver using the following configuration file.
  perl bin/driver.pl cfg/world.cfg -f %1 %2 %3

  if ERRORLEVEL 1 goto :ERRORS

    echo ****** Shutdown is fine.
    sleep 1
    echo ****** Stop me now, within few seconds...
    echo ****** ... or restart.
    sleep 8
    : pause
    goto START
:ERRORS
    echo ****** The driver is in a complete shambles.
    echo ****** Wait for 30 seconds and restart.
    sleep 30
    : pause

goto START
