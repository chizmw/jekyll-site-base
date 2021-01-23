FROM jekyll/jekyll:4 as jekyll

# DO NOT USE /srv/jekyll
# THERE'S A VOLUME in jekyll/jekyll:latest
# USING THAT LOCATION IS LIKE A BLACK HOLE FOR ANY FILES
# IN THERE
# we are building under our own rules, so we just work somewhere else
ENV TZ=UTC
ENV GEM_HOME        /myjekyll/gems
ENV JEKYLL_DEST     /myjekyll/jekyll/dest/
ENV JEKYLL_ENV      production
ENV JEKYLL_SRC      /myjekyll/jekyll/src/
ENV PATH            /myjekyll/gems/bin:$PATH

# do a bit of magic as root
USER root

RUN sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd
RUN useradd --create-home --shell /bin/bash jsite
RUN install -d -o jsite ${JEKYLL_DEST} ${GEM_HOME}
RUN install -d -o jsite ${JEKYLL_DEST} ${JEKYLL_DEST}
RUN install -d -o jsite ${JEKYLL_DEST} ${JEKYLL_SRC}

# we used to use WORKDIR, but kept ending up with root owned directories
# WORKDIR             ${JEKYLL_DEST}
# WORKDIR             ${JEKYLL_SRC}
# RUN chown -R jsite: ${JEKYLL_SRC} ${JEKYLL_DEST}
# Reading https://github.com/moby/moby/issues/36677#issuecomment-508277668
# it seems that we might as well just do things the old fashioned way

USER jsite

# create the workdir as non-root user
RUN mkdir -p ${JEKYLL_DEST} && mkdir -p ${JEKYLL_SRC}
WORKDIR             ${JEKYLL_SRC}

RUN     gem install bundler

# desperate sassc fix attempts
# https://github.com/sass/sassc-ruby/issues/146#issuecomment-541364174
RUN gem uninstall sassc && \
    gem install sassc -- --disable-march-tune-native
RUN bundle config --local build.sassc --disable-march-tune-native

COPY    Gemfile*    ${JEKYLL_SRC}
RUN     bundle install --full-index

ONBUILD     ENV GEM_HOME        /myjekyll/gems
ONBUILD     COPY    Gemfile*    ${JEKYLL_SRC}
ONBUILD     USER root
ONBUILD     RUN  chown -R jsite: ${JEKYLL_SRC}
ONBUILD     RUN  chown -R jsite: ${JEKYLL_DEST}
ONBUILD     USER jsite
ONBUILD     RUN  ls -l ${JEKYLL_SRC}
ONBUILD     RUN  bundle config --local build.sassc --disable-march-tune-native
ONBUILD     RUN  bundle config --local build.eventmachine --disable-march-tune-native
ONBUILD     RUN     bundle install --full-index
ONBUILD     COPY    .           ${JEKYLL_SRC}

ONBUILD     USER root
ONBUILD     RUN  chown -R jsite: ${JEKYLL_SRC}
ONBUILD     RUN  chown -R jsite: ${JEKYLL_DEST}
ONBUILD     USER jsite

ONBUILD     ARG jekyll_overrides
# set a default (of nothing) in case the ARG isn't passed
ONBUILD     ENV JEKYLL_OVERRIDES=${jekyll_overrides:-}

# JEKYLL_OVERRIDES is set where required in 01.nginx.proxy/docker-compose.yml
ONBUILD     RUN     echo +++ Using: --config _config.yml,${JEKYLL_OVERRIDES}
ONBUILD     RUN     bundle exec jekyll build --trace --destination ${JEKYLL_DEST} --config _config.yml,${JEKYLL_OVERRIDES}
ONBUILD     RUN     ls -larth ${JEKYLL_DEST}

#-----
#FROM    kyma/docker-nginx
#
#COPY --from=jekyll /tmp/site/ /var/www
#RUN     ls -l /var/www
#
#CMD     'nginx'
