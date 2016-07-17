FROM centos
EXPOSE 22 4403 8080 8000 9000
RUN yum update -y && yum -y install sudo openssh-server procps wget unzip mc git subversion curl nmap && mkdir /var/run/sshd && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && echo -e "codenvy2016\ncodenvy2016" | passwd user && sed -i 's/requiretty/!requiretty/g' /etc/sudoers

USER user
LABEL che:server:8080:ref=tomcat9 che:server:8080:protocol=http che:server:8000:ref=tomcat9-debug che:server:8000:protocol=http

ENV JAVA_VERSION=8u91 JAVA_VERSION_PREFIX=1.8.0_91 MAVEN_VERSION=3.3.9 GRADLE_VERSION=2.14 TOMCAT_VERSION=9.0.0.M9
ENV JAVA_HOME=/opt/jdk$JAVA_VERSION_PREFIX M2_HOME=/opt/apache-maven-$MAVEN_VERSION GRADLE_HOME=/opt/gradle-$GRADLE_VERSION TOMCAT_HOME=/home/user/tomcat9
ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$GRADLE_HOME/bin:$PATH

RUN sudo wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -qO- "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-b14/jdk-$JAVA_VERSION-linux-x64.tar.gz" | sudo tar -zx -C /opt/
RUN sudo mkdir /opt/apache-maven-$MAVEN_VERSION && sudo wget -qO- "https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" | sudo tar -zx --strip-components=1 -C /opt/apache-maven-$MAVEN_VERSION/
RUN sudo wget -q "https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip" && sudo unzip -q gradle-$GRADLE_VERSION-bin.zip -d /opt/ && sudo rm -f gradle-$GRADLE_VERSION-bin.zip

ENV TERM xterm
RUN mkdir /home/user/tomcat9 && wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" | tar -zx --strip-components=1 -C /home/user/tomcat9 && rm -rf /home/user/tomcat9/webapps/*

USER root
RUN echo -e "JAVA_HOME=/opt/jdk$JAVA_VERSION_PREFIX\nM2_HOME=/home/user/apache-maven-$MAVEN_VERSION\nGRADLE_HOME=/home/user/gradle-$GRADLE_VERSION\nTOMCAT_HOME=/home/user/tomcat9\nPATH=$JAVA_HOME/bin:$M2_HOME/bin:$GRADLE_HOME/bin:$PATH" >> /etc/environment

USER user
ENV LANG C.UTF-8
WORKDIR /projects
CMD sudo /usr/bin/ssh-keygen -A && sudo /usr/sbin/sshd -D && tail -f /dev/null