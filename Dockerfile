FROM jenkins/jenkins:lts
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

ARG docker_version=5:19.03.13~3-0~debian-stretch
ARG docker_compose_version=1.27.4
ARG virtualbox_version=6.1
ARG extpack_accept_key=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb

USER root
RUN echo "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list && \
    apt-get update && \
    apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      procps \
      software-properties-common \
      vim-tiny && \
   curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
   curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc > /tmp/vkey; apt-key add /tmp/vkey && \
   add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) \
     stable" && \
   add-apt-repository \
     "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian \
     $(lsb_release -cs) \
     contrib" && \
   apt-get update && \
   apt-get -y install \
     docker-ce=${docker_version} && \
   curl -fsSL "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose && \
     chmod 755 /usr/bin/docker-compose && \
   apt-get -y --no-install-recommends install \
     virtualbox-${virtualbox_version} && \
   cd /tmp && \
   curl -fsSLJO "$(curl -fsL "https://www.virtualbox.org/wiki/Downloads" | grep -oP "https://.*?vbox-extpack" | sort -V | head -n 1)" && \
     VBoxManage extpack install --accept-license=${extpack_accept_key} --replace *.vbox-extpack && \
   curl -o /tmp/vagrant.deb "https://releases.hashicorp.com$(curl -fsL "https://releases.hashicorp.com$(curl -fsL "https://releases.hashicorp.com/vagrant" | grep 'href="/vagrant/' | head -n 1 | grep -o '".*"' | tr -d '"' )" | grep "x86_64\.deb" | head -n 1 | grep -o 'href=".*"' | sed 's/href=//' | tr -d '"')" && \
      dpkg -i /tmp/vagrant.deb

ENV UID_JENKINS=1000
ENV GID_JENKINS=1000

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
