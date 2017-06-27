FROM bitnami/express:4.15.3-r2

MAINTAINER Bitnami <containers@bitnami.com>

USER root

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install -t jessie-backports -y openjdk-8-jdk-headless
RUN install_packages git subversion openssh-server rsync
RUN mkdir /var/run/sshd && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV BITNAMI_APP_NAME=che-express
ENV BITNAMI_IMAGE_VERSION=4.15.3-r2

# Install MongoDB module
RUN install_packages libssl1.0.0 libc6 libgcc1 libpcap0.8
RUN bitnami-pkg unpack mongodb-3.4.5-0 --checksum 6a9833ca2e46f89f7c05ebfae6402549f7ab7abeec485669eece25d28e762911
ENV PATH=/opt/bitnami/mongodb/sbin:/opt/bitnami/mongodb/bin:$PATH

RUN nami initialize mongodb

# Set up Codenvy integration
LABEL che:server:3000:ref=nodejs che:server:3000:protocol=http

RUN rm /app-entrypoint.sh

USER bitnami
WORKDIR /projects

ENV DATABASE_URL=mongodb://localhost:27017/my_project_development \
    TERM=xterm

ENTRYPOINT ["/entrypoint.sh"]
CMD sudo /usr/sbin/sshd && sudo env HOME=/root nami start --foreground mongodb

