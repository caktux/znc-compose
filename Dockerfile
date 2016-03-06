FROM ubuntu:wily
MAINTAINER caktux

ENV DEBIAN_FRONTEND noninteractive

# Create znc user
RUN adduser --system --group --home /var/znc --shell /bin/bash znc

# Usual update / upgrade
RUN apt-get update
RUN apt-get upgrade -q -y
RUN apt-get dist-upgrade -q -y

# Let our container upgrade itself
RUN apt-get install -q -y unattended-upgrades

# Install usual tools, always useful for introspection
RUN apt-get install -q -y wget vim

# Install dependencies
RUN apt-get install -q -y git build-essential automake libssl-dev libcurl4-openssl-dev libperl-dev libicu-dev libotr5-dev pkg-config

# Workaround to invalidate Docker's cache whenever the git repo changes
ADD https://api.github.com/repos/znc/znc/git/refs/heads/master no_git_cache

# Install ZNC
RUN git clone --depth=1 https://github.com/znc/znc.git
WORKDIR znc
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Install modules
# znc-otr
WORKDIR /
RUN git clone --depth=1 https://github.com/mmilata/znc-otr.git
WORKDIR znc-otr
RUN make
RUN mv otr.so /usr/local/lib/znc/

# znc-push
WORKDIR /
RUN git clone --depth=1 https://github.com/jreese/znc-push.git
WORKDIR /znc-push
RUN make
RUN mv push.so /usr/local/lib/znc/

# znc-playback
WORKDIR /
RUN git clone --depth=1 https://github.com/jpnurmi/znc-playback.git
WORKDIR /znc-playback
RUN znc-buildmod playback.cpp
RUN mv playback.so /usr/local/lib/znc/

WORKDIR /

# Install supervisor
RUN apt-get install -q -y supervisor

# Add supervisor configs
ADD supervisord.conf supervisord.conf

# Switch to znc user
USER znc
ENV HOME /var/znc

EXPOSE 6667
EXPOSE 6697

CMD ["-n", "-c", "/supervisord.conf"]
ENTRYPOINT ["/usr/bin/supervisord"]
