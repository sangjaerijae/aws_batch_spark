FROM amazoncorretto:latest AS spark

# Env variables
ENV SCALA_VERSION 2.12.10
ENV SBT_VERSION 1.3.4
ENV SPARK_VERSION 2.4.5

RUN yum install -y tar gzip procps wget which git python3 vim
RUN pip3 install awscli boto3

# Install spark 
RUN \ 
mkdir /opt/spark && \
curl -fsSL https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz | tar xfz - -C /opt/spark/ && \
echo >> /root/.bashrc && \
echo "export SPARK_HOME=/opt/spark/spark-2.4.5-bin-hadoop2.7" >> /root/.bashrc


# Install sbt
RUN \
mkdir /opt/sbt && \
curl -fsSL https://piccolo.link/sbt-1.3.8.tgz | tar xfz - -C /opt/ &&\
echo >> /root/.bashrc && \
echo "export SBT_HOME=/opt/sbt" >> /root/.bashrc 


# Install Scala
## Piping curl directly in tar
RUN \
mkdir /opt/scala && \
curl -fsSL https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz | tar xfz - -C /opt/scala/ && \
echo >> /root/.bashrc && \
echo "export SCALA_HOME=/opt/scala/scala-2.12.10" >> /root/.bashrc &&\
echo "export PATH=$PATH:/opt/spark/spark-2.4.5-bin-hadoop2.7/bin:/opt/sbt/bin:/opt/scala/scala-2.12.10/bin" >> /root/.bashrc

# install kubernetes <------ not supported region : us-west-1 (EKS)
RUN \ 
rm /opt/spark/spark-2.4.5-bin-hadoop2.7/jars/kubernetes-*-4.6.1.jar && \
wget https://repo1.maven.org/maven2/io/fabric8/kubernetes-model-common/4.6.1/kubernetes-model-common-4.6.1.jar -P /opt/spark/spark-2.4.5-bin-hadoop2.7/jars/ && \
wget https://repo1.maven.org/maven2/io/fabric8/kubernetes-client/4.6.1/kubernetes-client-4.6.1.jar -P /opt/spark/spark-2.4.5-bin-hadoop2.7/jars/ && \
wget https://repo1.maven.org/maven2/io/fabric8/kubernetes-model/4.6.1/kubernetes-model-4.6.1.jar -P /opt/spark/spark-2.4.5-bin-hadoop2.7/jars/

FROM spark AS build

USER root

#RUN source /root/.bashrc
ENV PATH $PATH:/opt/spark/spark-2.4.5-bin-hadoop2.7/bin:/opt/sbt/bin:/opt/scala/scala-2.12.10/bin

# build test
RUN \
sbt sbtVersion && \
mkdir /project && \
echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
echo "case object Temp" > Temp.scala && \
sbt compile && \
rm -r project && rm build.sbt && rm Temp.scala && rm -r target && \
mkdir -p /opt/sparkapp/project

# Define working directory
WORKDIR /opt/sparkapp

ENV SPARK_HOME /opt/sparkapp


# Project Definition layers change less often than application code
COPY build.sbt ./

WORKDIR /opt/sparkapp/project

# COPY project/*.scala ./ 
COPY project/build.properties ./
COPY project/assembly.sbt ./

WORKDIR /opt/sparkapp
#RUN sbt reload

FROM build AS final


#COPY --from=build /opt/sparkapp/target/scala-2.12/spark-on-ecs-assembly-v1.0.jar  /opt/sparkapp/jars

RUN echo SPARK_HOME

WORKDIR /opt/spark/work-dir

COPY --from=build /opt/spark/spark-2.4.5-bin-hadoop2.7/jars /opt/sparkapp/jars
COPY --from=build /opt/spark/spark-2.4.5-bin-hadoop2.7/bin /opt/sparkapp/bin
COPY --from=build /opt/spark/spark-2.4.5-bin-hadoop2.7/sbin /opt/sparkapp/sbin
COPY entrypoint.sh /opt/


# Copy rest of application
COPY . ./
#RUN sbt clean assembly


ENTRYPOINT [ "/opt/entrypoint.sh" ]
