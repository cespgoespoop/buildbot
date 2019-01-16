# buildbot/buildbot-worker
# fartz

# please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

FROM        fedora:29
MAINTAINER  Jake Harris


# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         DISTTAG=f29container FGC=f29 FBR=f29

# ADD fedora-29-x86_64-20181106.tar.xz \
# Install security updates and required packages
RUN         dnf -yq upgrade && \
    dnf install -yq \
    git \
    subversion \
    python3-devel \
    libffi-devel \
    openssl-devel \
    python3-setuptools \
    python2-devel \
    dumb-init \
    curl && \
    dnf -yq groupinstall "Development Tools" && \
    easy_install-3.7 pip && \
    # Install required python packages, and twisted
    pip --no-cache-dir install 'twisted[tls]' && \
    mkdir /buildbot &&\
    useradd -ms /bin/bash buildbot

COPY . /usr/src/buildbot-worker
COPY docker/buildbot.tac /buildbot/buildbot.tac

RUN pip3 install /usr/src/buildbot-worker && \
    chown -R buildbot /buildbot

USER buildbot
WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
