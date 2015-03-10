nfldata
=======

The are two series of MapReduce programs.  One is a series of programs to extract and normalize the data.  The second is a simple program to look at incomplete passes.  

The play by play dataset can be found at
http://www.advancednflstats.com/2010/04/play-by-play-data.html.   

ETL Series
==========

This program takes the play by play dataset and merges it with other datasets like arrests, stadiums and weather.   

Set things up by running the setup_nfldemo.sh script or by running the individual steps manually.

See the queries in example_queries.hql for some examples of how and what to query.   



Play Search
===========

Based on merged dataset from above ETL Series. Data is parsed using Morphlines and indexed using MapReduceIndexerTool. 

Setup the play search by editing & running the setupsearch.sh script. Script should work with no changes on quickstart VM.
Otherwise you will need to fill env variables for ZK ensemble and base directories. 

