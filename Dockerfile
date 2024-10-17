FROM ubuntu:22.04

RUN apt-get update -y \
    && apt-get upgrade -y \ 
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        sudo \
        wget maven \
        vim tmux \
        openssh-server openssh-client ssh-askpass
RUN apt-get install -y --no-install-recommends openjdk-8-jdk
RUN apt-get clean
    
# # RUN useradd -m hduser && echo "hduser:supergroup" | chpasswd && adduser hduser sudo && echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ && sudo ln -s python3 python
# USER root
# COPY ./etc/ssh_config /etc/ssh/ssh_config

# # WORKDIR /home/hduser
# RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N "" \
#     && ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N "" \
#     && ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""
# RUN service ssh status 
RUN service ssh start 
RUN sshd -t

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys


WORKDIR /root
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_HOME /opt/hadoop/hadoop-${HADOOP_VERSION}
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
RUN wget "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz" 
# RUN wget "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" 
RUN gunzip hadoop-${HADOOP_VERSION}.tar.gz
RUN mkdir /opt/hadoop
RUN tar -x -C /opt/hadoop/ -f hadoop-${HADOOP_VERSION}.tar
# #  && rm -rf ${HADOOP_HOME}/share/doc

ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root

ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root


COPY ./etc/hadoop-env.sh.append /root/hadoop-env.sh.append
RUN cat "/root/hadoop-env.sh.append" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY ./etc/.bashrc.append /root/.bashrc.append
RUN cat "/root/.bashrc.append" >> /root/.bashrc

COPY ./etc/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./etc/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY ./etc/yarn-site.xml $HADOOP_HOME/etc/hadoop/



# ADD examples/ examples/ 

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

# WORKDIR /usr/local/bin
# RUN sudo ln -s ${HADOOP_HOME}/etc/hadoop/docker-entrypoint.sh .
# WORKDIR /home/hduser

# # YARNSTART=0 will prevent yarn scheduler from being launched
ENV YARNSTART 0

COPY docker-entrypoint.sh /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]