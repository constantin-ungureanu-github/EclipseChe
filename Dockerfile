FROM centos
EXPOSE 22 4403 8080 8000 9000
RUN yum update -y && yum -y install sudo openssh-server procps wget unzip mc git subversion curl nmap && mkdir /var/run/sshd && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && echo -e "codenvy2016\ncodenvy2016" | passwd user && sed -i 's/requiretty/!requiretty/g' /etc/sudoers

USER user
LABEL che:server:8080:ref=tomcat8 che:server:8080:protocol=http che:server:8000:ref=tomcat8-debug che:server:8000:protocol=http

ENV JAVA_MAJOR_VERSION=131 JAVA_MINOR_VERSION=b11 JAVA_VERSION=8u$JAVA_MAJOR_VERSION JAVA_VERSION_PREFIX=1.8.0_$JAVA_MAJOR_VERSION JAVA_HOME=/opt/jdk-$JAVA_VERSION_PREFIX
ENV SCALA_VERSION=2.12.2 SCALA_HOME=/opt/scala-$SCALA_VERSION
ENV ANT_VERSION=1.10.1 ANT_HOME=/opt/apache-ant-$ANT_VERSION 
ENV MVN_VERSION=3.5.0 MVN_HOME=/opt/apache-maven-$MVN_VERSION 
ENV GRADLE_VERSION=4.0 GRADLE_HOME=/opt/gradle-$GRADLE_VERSION 
ENV SBT_VERSION=0.13.15 SBT_HOME=/opt/sbt-$SBT_VERSION
ENV PATH=$JAVA_HOME/bin:$SCALA_HOME/bin:$ANT_HOME/bin:$MVN_HOME/bin:$GRADLE_HOME/bin:$SBT_HOME/bin:$PATH

ENV TOMCAT_VERSION=8.5.15 TOMCAT_HOME=/home/user/tomcat8

RUN sudo wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -qO- "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_MINOR_VERSION/d54c1d3a095b4ff2b6607d096fa80163/jdk-$JAVA_VERSION-linux-x64.tar.gz" | sudo tar -zx -C /opt/
RUN sudo wget -qO- "https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz" | sudo tar -zx -C /opt/
RUN sudo mkdir /opt/apache-ant-$ANT_VERSION && sudo wget -qO- "https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" | sudo tar -zx --strip-components=1 -C $ANT_HOME/
RUN sudo mkdir /opt/apache-maven-$MVN_VERSION && sudo wget -qO- "https://www.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz" | sudo tar -zx --strip-components=1 -C $MVN_HOME/
RUN sudo wget -q "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" && sudo unzip -q gradle-$GRADLE_VERSION-bin.zip -d /opt/ && sudo rm -f gradle-$GRADLE_VERSION-bin.zip
RUN sudo mkdir /opt/sbt-$SBT_VERSION && sudo wget -qO- "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" | sudo tar -zx --strip-components=1 -C $SBT_HOME/

ENV TERM xterm
RUN mkdir /home/user/tomcat8 && wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat8 && rm -rf /home/user/tomcat8/webapps/*

USER root
RUN echo -e "JAVA_HOME=$JAVA_HOME\nSCALA_HOME=$SCALA_HOME\nANT_HOME=$ANT_HOME\nMVN_HOME=$MVN_HOME\nGRADLE_HOME=$GRADLE_HOME\nSBT_HOME=$SBT_HOME\nTOMCAT_HOME=$TOMCAT_HOME\nPATH=$JAVA_HOME/bin:$SCALA_HOME/bin:$ANT_HOME/bin:$MVN_HOME/bin:$GRADLE_HOME/bin:$SBT_HOME/bin:$PATH" >> /etc/environment

USER user
ENV LANG C.UTF-8
WORKDIR /projects
CMD sudo /usr/bin/ssh-keygen -A && sudo /usr/sbin/sshd -D && tail -f /dev/null
