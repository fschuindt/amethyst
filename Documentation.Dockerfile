# This Dockerfile shall only be used to create a
# "amethyst_documentation" Docker image to be used within Kubernetes.
# For all other purposes you can keep using the regular Dockerfile.

FROM sebp/lighttpd

RUN mkdir -p /var/www/localhost/htdocs/

COPY ./doc/. /var/www/localhost/htdocs/.

EXPOSE 80

