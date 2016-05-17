FROM pulsepointinc/centos7-java8 

CMD ["/start.sh"]

COPY files/etc/yum.repos.d/confluent.repo /etc/yum.repos.d/confluent.repo

RUN \
  rpm --rebuilddb && \
  rpm --import http://packages.confluent.io/rpm/1.0/archive.key && \
  yum install -y confluent-kafka-2.10.4 && \
  yum clean all

COPY files/start.sh /start.sh
