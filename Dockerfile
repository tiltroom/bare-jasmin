FROM ubuntu:bionic

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r jasmin && useradd -r -g jasmin jasmin

ENV JASMIN_VERSION 0.9.31

# Install requirements
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python2.7-dev \
    libffi-dev \
    libssl-dev \
    supervisor \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Jasmin SMS gateway
RUN mkdir -p /etc/jasmin/resource \
    /etc/jasmin/store \
    /var/log/jasmin \
  && chown jasmin:jasmin /etc/jasmin/store \
    /var/log/jasmin \
  && pip install --pre jasmin=="$JASMIN_VERSION"

RUN sed -i '/\[jcli\]/a bind=0.0.0.0' /etc/jasmin/jasmin.cfg

COPY docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["jasmind.py", "--enable-interceptor-client", "--enable-dlr-thrower", "--enable-dlr-lookup", "-u", "jcliadmin", "-p", "jclipwd"]
# Notes:
# - jasmind is started with native dlr-thrower and dlr-lookup threads instead of standalone processes
# - restapi (0.9rc16+) is not started in this docker configuration
