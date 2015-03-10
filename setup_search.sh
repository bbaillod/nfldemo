#!/bin/bash

echo "Setting up env"
echo "  "
# Change this to your zookeeper host:port/solr
export SOLR_ZK_ENSEMBLE=10.0.1.100:2181/solr

# Update cloudera to another user if necessary
export BASE_DIR=/cloudera/workspace/nfldata
export PROJECT_HOME=$BASE_DIR/nflsearch
export CLOUDERA_SEARCH_MR_PATH=/opt/cloudera/parcels/CDH-5.3.1-1.cdh5.3.1.p0.5/lib/solr/contrib/mr/search-mr-1.0.0-cdh5.3.1-job.jar
export HDFS_AUTHORITY=10.0.1.100
export COLLECTION_NAME=NFL-Collection
export CURRENT_USER=cloudera

echo "Cleanup any old configs"
{
        solrctl --zk $SOLR_ZK_ENSEMBLE instancedir --delete $COLLECTION_NAME
        solrctl --zk $SOLR_ZK_ENSEMBLE collection --delete $COLLECTION_NAME
        rm -rf $PROJECT_HOME
}
echo "Setup config directory"
solrctl  instancedir --generate $PROJECT_HOME
cp $BASE_DIR/schema.xml $PROJECT_HOME/conf/schema.xml
cp $BASE_DIR/log4j.properties $PROJECT_HOME/log4j.properties


solrctl --zk $SOLR_ZK_ENSEMBLE instancedir --create $COLLECTION_NAME $PROJECT_HOME
solrctl --zk $SOLR_ZK_ENSEMBLE collection --create $COLLECTION_NAME -s 1

hadoop jar $CLOUDERA_SEARCH_MR_PATH org.apache.solr.hadoop.MapReduceIndexerTool -D 'mapred.child.java.opts=-Xmx500m' --log4j $PROJECT_HOME/log4j.properties --morphline-file $BASE_DIR/nflmorphlines.conf --output-dir hdfs://$HDFS_AUTHORITY/user/$CURRENT_USER/nflsearchdata/ --verbose --go-live --zk-host $SOLR_ZK_ENSEMBLE --collection $COLLECTION_NAME  hdfs://$HDFS_AUTHORITY/user/hive/warehouse/playbyplay/