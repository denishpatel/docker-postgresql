FROM quay.io/aptible/ubuntu:12.10

# Install PostgreSQL 9.3.x from official Debian sources
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ADD templates/etc/apt/sources.list.d /etc/apt/sources.list.d
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
      B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    apt-get update && \
    apt-get -y install python-software-properties software-properties-common \
      postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres

# Install self-signed certificate and disallow non-SSL connections
ADD templates/etc/postgresql/9.3/main /etc/postgresql/9.3/main
WORKDIR /var/lib/postgresql/9.3/main
RUN openssl req -new -newkey rsa:1024 -days 365000 -nodes -x509 \
      -keyout server.key -subj "/CN=PostgreSQL" -out server.crt && \
    chmod og-rwx server.key

ADD test /tmp/test
RUN bats /tmp/test

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432

CMD ["/usr/lib/postgresql/9.3/bin/postgres", \
     "-D", "/var/lib/postgresql/9.3/main", \
     "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
