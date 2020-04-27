FROM azul/zulu-openjdk-centos:8u252
MAINTAINER rafaelszp

 RUN groupadd -g 1001 pentaho \
    && useradd -r -u 1001 -g pentaho pentaho

RUN yum install -y findutils unzip zip wget curl ca-certificates

ENV PDI_USER=pentaho \
        KETTLE_HOME=/pdi/data-integration POSTGRESQL_DRIVER_VERSION=42.1.1 \
        MYSQL_DRIVER_VERSION=5.1.42 JTDS_VERSION=1.3.1 CASSANDRA_DRIVER_VERSION=0.6.3 \
        H2DB_VERSION=1.4.196 HSQLDB_VERSION=2.4.0

ENV DL_LINK="https://ufpr.dl.sourceforge.net/project/pentaho/Pentaho%209.0/client-tools/pdi-ce-9.0.0.0-423.zip"

RUN mkdir /pdi -p

RUN wget --progress=dot:giga $DL_LINK \
        -O /pdi/pdi-ce-9.0.0.0-423.zip \
        && unzip -q /pdi/*.zip -d /pdi  \
        && rm -f /pdi/pdi-ce-9.0.0.0-423.zip \
        && chown pentaho:pentaho /pdi -R \
        && chmod "g+rwX" /pdi/data-integration/*.sh  \
        && ls /pdi -l

RUN $(wget --progress=dot:giga https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
                https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
                https://repo1.maven.org/maven2/net/sourceforge/jtds/jtds/${JTDS_VERSION}/jtds-${JTDS_VERSION}.jar \
                https://repo1.maven.org/maven2/com/h2database/h2/${H2DB_VERSION}/h2-${H2DB_VERSION}.jar \
                https://repo1.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar \
        && mv *.jar /pdi/data-integration/lib/.) || echo 'houve algum erro'

ENTRYPOINT ["/pdi/data-integration/kitchen.sh"]