# As of March 18, 2020 - corona virus scare time

# https://www.debian.org/releases/
FROM debian:stretch

MAINTAINER Mike Babineau michael.babineau@gmail.com

ENV DEBIAN_FRONTEND="noninteractive"

# Ref: https://stackoverflow.com/questions/57031649/how-to-install-openjdk-8-jdk-on-debian-10-buster
RUN apt-get update -y && apt-get install curl maven wget gnupg software-properties-common openjdk-8-jdk-headless openjdk-8-jdk -y \
    && curl -Lo /tmp/zookeeper.tar.gz "https://downloads.apache.org/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz" \
    && mkdir -p /opt/zookeeper/transactions /opt/zookeeper/snapshots \
    && tar -xvf /tmp/zookeeper.tar.gz -C /opt/zookeeper --strip=1 \
    && rm /tmp/zookeeper.tar.gz \
    # Install Exhibitor
    && mkdir -p /opt/exhibitor \
    && curl -Lo /opt/exhibitor/pom.xml "https://raw.githubusercontent.com/Netflix/exhibitor/master/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml" \
    && mvn -f /opt/exhibitor/pom.xml package \
    && ln -s /opt/exhibitor/target/exhibitor*jar /opt/exhibitor/exhibitor.jar \
    # Remove build-time dependencies
    && apt-get purge -y --auto-remove curl maven wget gnupg software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add the wrapper script to setup configs and exec exhibitor
ADD include/wrapper.sh /opt/exhibitor/wrapper.sh

# Add the optional web.xml for authentication
ADD include/web.xml /opt/exhibitor/web.xml

USER root

WORKDIR /opt/exhibitor

EXPOSE 2181 2888 3888 8181

ENTRYPOINT ["bash", "-ex", "/opt/exhibitor/wrapper.sh"]

#ENTRYPOINT ["sleep", "1000000000"]

# TODO - make wrapper.sh run completely and also modify defaults.conf to include backup dir and other variables. Give pr to Dhruv, Zach and Kevin.

