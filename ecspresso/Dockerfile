FROM ubuntu:20.04
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/kayac/ecspresso/releases/download/v1.6.2/ecspresso_1.6.2_linux_amd64.tar.gz \
  && tar -xvf ecspresso_1.6.2_linux_amd64.tar.gz \
  && install ecspresso /usr/local/bin
CMD [ "ecspresso" ]