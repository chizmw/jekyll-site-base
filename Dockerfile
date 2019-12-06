FROM jekyll/jekyll:4 as jekyll

# DO NOT USE /srv/jekyll
# THERE'S A VOLUME in jekyll/jekyll:latest
# USING THAT LOCATION IS LIKE A BLACK HOLE FOR ANY FILES
# IN THERE
# we are building under our own rules, so we just work somewhere else
ENV TZ=UTC
ENV GEM_HOME        /tmp/gems
ENV JEKYLL_DEST     /tmp/jekyll/dest/
ENV JEKYLL_ENV      production
ENV JEKYLL_SRC      /tmp/jekyll/src/
ENV PATH            /tmp/gems/bin:$PATH

RUN sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd
RUN useradd --create-home --shell /bin/bash jsite
USER jsite

WORKDIR             ${JEKYLL_DEST}
WORKDIR             ${JEKYLL_SRC}

COPY    Gemfile*    ${JEKYLL_SRC}
RUN     bundle install --full-index

ONBUILD		COPY    Gemfile*    ${JEKYLL_SRC}
ONBUILD		RUN     bundle install --full-index
ONBUILD		COPY    .           ${JEKYLL_SRC}

ONBUILD		USER root
ONBUILD		RUN  chown -R jsite: ${JEKYLL_SRC}
ONBUILD		RUN  chown -R jsite: ${JEKYLL_DEST}
ONBUILD		USER jsite

ONBUILD		ARG jekyll_overrides
# set a default (of nothing) in case the ARG isn't passed
ONBUILD		ENV JEKYLL_OVERRIDES=${jekyll_overrides:-}

# JEKYLL_OVERRIDES is set where required in 01.nginx.proxy/docker-compose.yml
ONBUILD		RUN     echo +++ Using: --config _config.yml,${JEKYLL_OVERRIDES}
ONBUILD		RUN     jekyll build --trace --destination ${JEKYLL_DEST} --config _config.yml,${JEKYLL_OVERRIDES}
ONBUILD		RUN     ls -larth ${JEKYLL_DEST}

#-----
#FROM    kyma/docker-nginx
#
#COPY --from=jekyll /tmp/site/ /var/www
#RUN     ls -l /var/www
#
#CMD     'nginx'
