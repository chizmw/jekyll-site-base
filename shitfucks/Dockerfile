FROM chizcw/jekyll-site-base:c5487a8 as jekyll-composed

# inherit lots of ONBUILD magic
# if we haven't changed anything upstream our generated site will be output to
# /tmp/jekyll/dest/

RUN echo $GEM_HOME

#-----
FROM    kyma/docker-nginx

COPY --from=jekyll-composed /tmp/jekyll/dest/ /var/www
RUN     ls -lah /var/www

CMD     'nginx'
