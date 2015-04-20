#/bin/bash

BASEDIR=/user/cloudera

echo "Compiling NFL PlaybyPlay Parser Java MapReduce Program"
cd src
javac -classpath `hadoop classpath` *.java
jar cf ../playbyplay.jar *.class
cd ..

echo "Deleting files in HDFS, disregard error if they are not there already"
echo " "
hadoop fs -rm -r $BASEDIR/nfl_play_csv_files
hadoop fs -rm -r $BASEDIR/parsed_plays
hadoop fs -rm -r $BASEDIR/playbyplay_arrests
hadoop fs -rm -r $BASEDIR/weather_csv_files
hadoop fs -rm -r $BASEDIR/stadium_csv_files

echo "Putting Play, Weather, Stadium, and arrest files into HDFS"
echo " "
hadoop fs -put -f nfl_play_csv_files $BASEDIR/
hadoop fs -put -f weather_csv_files $BASEDIR/
hadoop fs -put -f stadium_csv_files $BASEDIR/
hadoop fs -put -f arrest_csv_files  $BASEDIR/

echo "Running PlaybyPlay Parser MapReduce Job to create the parsed_plays file"
echo " "
hadoop jar playbyplay.jar PlayByPlayDriver $BASEDIR/nfl_play_csv_files $BASEDIR/parsed_plays

echo "Running Arrest Joiner MapReduce Job to create playbyplay_arrests file"
echo " "
hadoop jar playbyplay.jar ArrestJoinDriver $BASEDIR/parsed_plays $BASEDIR/playbyplay_arrests $BASEDIR/arrest_csv_files/arrests.csv

echo "Creating Hive Tables"
echo " "
hive -S -f /sql/create_hive_tables.hql

echo "Join Weather Data to playbyplay_arrests to create playbyplay_weather"
echo " "
hive -S -f /sql/weather_join.hql

echo "Sessionize drives (Play 3 of 9) to create playbyplay_drives"
echo " "
hive -S -f /sql/sessionize_drives.hql

echo "Calculate the result of the drive (drive ended with Punt).  This creates the final playbyplay table"
echo " "
hive -S -f /sql/result_of_drive.hql

echo "All done with NFL Demo data creation"
echo ""
echo ""
echo "** There are some sample SQL and PIG queries in queries.hql and queries.pig **"
