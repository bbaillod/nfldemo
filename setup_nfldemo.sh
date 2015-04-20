#/bin/bash

BASEDIR=/user/cloudera

echo "Compiling NFL PlaybyPlay Parser Java MapReduce Program"
echo " "
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
hadoop fs -put -f arrests.csv       $BASEDIR/

echo "Running PlaybyPlay Parser MapReduce Job to read the nfl_play_csv_files and create the parsed_plays output file"
echo " "
hadoop jar playbyplay.jar PlayByPlayDriver $BASEDIR/nfl_play_csv_files $BASEDIR/parsed_plays

echo "Running Arrest Joiner MapReduce Job to create playbyplay_arrests file"
echo " "
hadoop jar playbyplay.jar ArrestJoinDriver $BASEDIR/parsed_plays $BASEDIR/playbyplay_arrests $BASEDIR/arrests.csv


echo "Creating Hive Tables"
echo " "
cd sql
hive -S -f create_hive_tables.hql

echo "Join Weather Data to playbyplay_arrests to create playbyplay_weather"
echo " "
hive -S -f ./sql/weather_join.hql

echo "Sessionize drives to create playbyplay_drives i.e. play 3 of 9"
echo " "
hive -S -f ./sql/sessionize_drives.hql

echo "Calculate the result of the drive (drive ended with Punt).  This creates the final playbyplay table"
echo " "
hive -S -f ./sql/result_of_drive.hql

echo "All done with NFL Demo data creation"
echo ""
echo ""
echo "** There are some sample SQL and PIG queries in these files: queries.hql and queries.pig **"
