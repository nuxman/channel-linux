FROM centos:7
MAINTAINER "rbraga@tce.ro.gov.br"
RUN yum -y install zsh \
                    git \
                    bzip2 \
                    unzip \
                    openssl \
                    which \
                    wget \
                    gcc \
                    gcc-c++ \
                    openssl-devel \
                    freetype-devel \
                    fontconfig-devel \
                    libfreetype.so.6 \
                    libfontconfig.so.1 \
                    libstdc++.so.6 \
                    urw-fonts && yum clean all

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
ENV JAVA_HOME /usr/java/jdk1.6.0_45
ENV JBOSS_HOME /usr/java/jboss
ENV LANG pt_BR.ISO-8859-1
ENV LANGUANGE pt_BR.ISO-8859-1

RUN fc-cache -vf

RUN mkdir /usr/java

WORKDIR /usr/java

COPY jdk-linux-x64.rpm.bin .
RUN sh jdk-linux-x64.rpm.bin
RUN rm jdk-linux-x64.rpm.bin
COPY jboss.tar.gz /usr/java
RUN tar xzvf jboss.tar.gz

WORKDIR /usr/java/jboss

#create a jboss group and app user
RUN  adduser --uid 1000 \
    -d /home/jboss \
    -m \
    -p $(openssl passwd ch4nn31) \
    -s $(which zsh) \
    jboss


COPY phantomjs.tar.gz /usr/java/jboss
RUN tar xzvf phantomjs.tar.gz
COPY c3p0-service.xml /usr/java/jboss/server/channel/deploy
COPY jexp.ini /usr/java/jboss/server/channel/jexp.ini
COPY server.xml /usr/java/jboss/server/channel/deploy/jbossweb-tomcat50.sar
COPY wrapperChannel.conf /usr/java/jboss/conf
COPY channel_postgres.ear /usr/java/jboss/server/channel/deploy

RUN wget ftp://fr2.rpmfind.net/linux/sourceforge/p/po/postinstaller/fedora/releases/22/i386/msttcorefonts-2.5-1.fc22.noarch.rpm
RUN rpm -Uvh msttcorefonts-2.5-1.fc22.noarch.rpm
RUN chmod +x /usr/java/jboss/bin/run.sh
RUN chmod -R 744 /usr/java/jboss

EXPOSE 8888 8009 8443

CMD ["/usr/java/jboss/bin/run.sh ","-c", "channel"]
