winpty docker run -it aws_batch_spark:v2.4.5 submit --master local[*] --class org.apache.spark.examples.SparkPi /opt/spark/spark-2.4.5-bin-hadoop2.7/examples/jars/spark-examples_2.11-2.4.5.jar 100
