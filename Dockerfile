ARG BASE_IMAGE=debian:9
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2019-03-09

LABEL Name="senzing/python-postgresql-base" \
      Version="1.0.0"

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
      curl \
      gnupg \
      jq \
      libmysqlclient-dev \
      lsb-core \
      lsb-release \
      python-dev \
      python-pip \
      python-pyodbc \
      sqlite \
      unixodbc \
      unixodbc-dev \
      wget \
 && rm -rf /var/lib/apt/lists/*

# Install libmysqlclient21.

ENV DEBIAN_FRONTEND=noninteractive
RUN wget -qO - https://repo.mysql.com/RPM-GPG-KEY-mysql | apt-key add - \
 && wget https://repo.mysql.com/mysql-apt-config_0.8.11-1_all.deb \
 && dpkg --install mysql-apt-config_0.8.11-1_all.deb \
 && apt-get update \
 && apt-get -y install libmysqlclient21 \
 && rm mysql-apt-config_0.8.11-1_all.deb \
 && rm -rf /var/lib/apt/lists/*

# Create MySQL connector.
# References:
#  - https://dev.mysql.com/downloads/connector/odbc/
#  - https://dev.mysql.com/doc/connector-odbc/en/connector-odbc-installation-binary-unix-tarball.html

RUN wget https://cdn.mysql.com//Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit.tar.gz \
 && tar -xvf mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit.tar.gz \
 && cp mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit/lib/* /usr/lib/x86_64-linux-gnu/odbc/ \
 && mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit/bin/myodbc-installer -d -a -n "MySQL" -t "DRIVER=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so;" \
 && rm mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit.tar.gz \
 && rm -rf mysql-connector-odbc-8.0.13-linux-ubuntu18.04-x86-64bit

# Work-around. https://senzing.zendesk.com/hc/en-us/articles/360009212393-MySQL-V8-0-ODBC-client-alongside-V5-x-Server

RUN wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-libs-8.0.12-1.el7.x86_64.rpm \
 && rpm2cpio mysql-community-libs-8.0.12-1.el7.x86_64.rpm | cpio -idmv

# Install packages via pip.

RUN pip install \
    psutil \
    pyodbc

# Environment variables.

ENV SENZING_ROOT=/opt/senzing
ENV PYTHONPATH=${SENZING_ROOT}/g2/python
ENV LD_LIBRARY_PATH=${SENZING_ROOT}/g2/lib:${SENZING_ROOT}/g2/lib/centos

# Copy files from repository.

COPY ./rootfs /

# Runtime execution.

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["python"]
