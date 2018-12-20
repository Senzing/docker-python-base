ARG BASE_CONTAINER=centos:latest
FROM ${BASE_CONTAINER}

ENV REFRESHED_AT=2018-10-15

# Install prerequisites.

RUN yum -y update; yum clean all
RUN yum -y install epel-release; yum clean all
RUN yum -y install \
    gcc-c++ \
    mysql-connector-odbc \
    python-devel \
    python-pip \
    unixODBC \
    unixODBC-devel \
    wget; \
    yum clean all

RUN pip install \
    psutil \
    pyodbc

# Environment variables.

ENV SENZING_ROOT=/opt/senzing
ENV PYTHONPATH=${SENZING_ROOT}/g2/python
ENV LD_LIBRARY_PATH=${SENZING_ROOT}/g2/lib:${SENZING_ROOT}/g2/lib/centos

# Copy files from repository.

COPY ./root /

# Work-around https://senzing.zendesk.com/hc/en-us/articles/360009212393-MySQL-V8-0-ODBC-client-alongside-V5-x-Server

RUN wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-libs-8.0.12-1.el7.x86_64.rpm \
 && rpm2cpio mysql-community-libs-8.0.12-1.el7.x86_64.rpm | cpio -idmv

# Runtime execution.

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["python"]
