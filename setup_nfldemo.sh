#/bin/bash

BASEDIR=/user/cloudera

echo "Compiling NFL PlaybyPlay Parser Java MapReduce Program"
cd src
javac -classpath `hadoop classpath` *.java
jar cf ../playbyplay.jar *.class
cd ..

echo "Deleting files in HDFS, disregard error if they are not there already"
echo " "
hadoop fs -rm -r $BASEDIR/input
hadoop fs -rm -r $BASEDIR/playoutput
hadoop fs -rm -r $BASEDIR/joinedoutput
hadoop fs -rm -r $BASEDIR/weather
hadoop fs -rm -r $BASEDIR/stadium

echo "Putting Play, Weather, Stadium, and arrest files into HDFS"
echo " "
hadoop fs -put -f nfl_play_csv_files $BASEDIR/nfl_play_csv_files/
hadoop fs -mkdir $BASEDIR/weather_csv_files
hadoop fs -put -f /weather_csv_files/weather.csv $BASEDIR/weather/
hadoop fs -mkdir $BASEDIR/stadium_csv_files
hadoop fs -put -f /stadium_csv_files/stadiums.csv $BASEDIR/stadium_csv_files/
hadoop fs -put -f /arrest_csv_files/arrests.csv $BASEDIR/arrest_csv_files/arrests.csv 

echo "Running PlaybyPlay Parser MapReduce Job"
echo " "
hadoop jar playbyplay.jar PlayByPlayDriver $BASEDIR/input $BASEDIR/playoutput

echo "Running Arrest Joiner MapReduce Job"
echo " "
hadoop jar playbyplay.jar ArrestJoinDriver $BASEDIR/playoutput $BASEDIR/joinedoutput $BASEDIR/arrests.csv

echo "Creating Hive Tables"
echo " "
hive -S -f create_hive_tables.hql

echo "Join Weather Data to PlayByPlay + Arrests"
echo " "
hive -S -f weather_join.hql

echo "Sessionize drives (Play 3 of 9)"
echo " "
hive -S -f sessionize_drives.hql

echo "Calculate the result of the drive (drive ended with Punt)"
echo " "
hive -S -f result_of_drive.hql

echo "All done with NFL Demo data creation"
echo ""
echo ""
echo "** Check the Hive and Pig output in queries.hql and queries.pig **"
