FROM ubuntu:utopic
MAINTAINER caktux

ENV DEBIAN_FRONTEND noninteractive

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

# Install ZNC, too many workdir changes so we `cd` each time
RUN git clone --depth=1 https://github.com/znc/znc.git
RUN cd znc && git submodule update --init --recursive
RUN cd znc && ./autogen.sh
RUN cd znc && ./configure
RUN cd znc && make
RUN cd znc && make install

# Install modules
# znc-otr
RUN git clone --depth=1 https://github.com/mmilata/znc-otr.git
RUN cd znc-otr && make
RUN mv znc-otr/otr.so /usr/local/lib/znc/

# znc-push
RUN git clone --depth=1 https://github.com/jreese/znc-push.git
RUN cd znc-push && make
RUN mv znc-push/push.so /usr/local/lib/znc/

# znc-playback
RUN git clone --depth=1 https://github.com/jpnurmi/znc-playback.git
RUN cd znc-playback && znc-buildmod playback.cpp
RUN mv znc-playback/playback.so /usr/local/lib/znc/

# Install supervisor
RUN apt-get install -q -y supervisor

# Add supervisor configs
ADD supervisord.conf supervisord.conf

# Create znc user since it complains like a little bitch about being root
RUN adduser --system --group --home /var/znc --shell /bin/bash znc
USER znc
ENV HOME /var/znc

EXPOSE 6697

CMD ["-n", "-c", "/supervisord.conf"]
ENTRYPOINT ["/usr/bin/supervisord"]
