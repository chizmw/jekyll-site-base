FROM jekyll/jekyll:latest as jekyll

WORKDIR             /srv/jekyll/

ENV GEM_HOME        /tmp/gems
ENV PATH            /tmp/gems/bin:$PATH

COPY    Gemfile     /srv/jekyll/
RUN     bundle install

COPY    .            /srv/jekyll/

ENV     JEKYLL_ENV      production
RUN     jekyll build --destination /tmp/site
RUN     ls -larth /tmp/site

#-----
FROM    kyma/docker-nginx

COPY --from=jekyll /tmp/site/ /var/www
RUN     ls -l /var/www

CMD     'nginx'
