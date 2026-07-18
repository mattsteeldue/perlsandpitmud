#
# mud.sh
#

# since this file is located under ./bin go up one level
cd ..

mkdir -p log

while [ 1 == 1 ]
  do
  # starts driver using the following configuration file.
  perl bin/driver.pl cfg/world.cfg -f %1 %2 %3
  RC=$?
  if [ $RC -eq 0 ]
  then
    echo ****** Shutdown is fine.
    sleep 1
    echo ****** Stop me now, within few seconds...
    echo ****** ... or restart.
    sleep 8
    # read

  else
    echo ****** The driver is in a complete shambles.
    echo ****** Wait for 30 seconds and restart.
    sleep 30
    # read
  fi
done        
