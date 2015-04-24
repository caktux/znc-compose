FROM ubuntu:utopic
MAINTAINER caktux

# Create znc user since it complains like a little bitch about being root
RUN adduser --system --group --home /var/znc --shell /bin/bash znc

# Create SSL cert and configs, comment if importing your own .znc folder
RUN mkdir /var/znc/.znc
RUN znc --makepem
RUN znc --makeconf

# Import our data, add your curent `.znc` folder as a subfolder
# of `data` and uncomment below. Do this only once, and don't forget
# to go back to using `image` instead of `build` in `docker-compose.yml`
# ADD .znc /var/znc/.znc
# RUN chown -R znc:znc /var/znc/.znc
