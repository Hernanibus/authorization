# Generate the HTML output.
FROM markstory/cakephp-docs-builder as builder

COPY docs /data/docs

ENV LANGS="en"

# Build docs with sphinx
RUN cd /data/docs-builder && \
  make website SOURCE=/data/docs DEST=/data/website

# Build a small nginx container with just the static site in it.
FROM markstory/cakephp-docs-builder:runtime as runtime

# Configure search index script
ENV LANGS="en"
ENV SEARCH_SOURCE="/usr/share/nginx/html"
ENV SEARCH_URL_PREFIX="/authorization/1"

COPY --from=builder /data/docs /data/docs
COPY --from=builder /data/website /data/website
COPY --from=builder /data/docs-builder/nginx.conf /etc/nginx/conf.d/default.conf

# Move files into final location
RUN cp -R /data/website/html/* /usr/share/nginx/html \
  && rm -rf /data/website/

RUN ln -s /usr/share/nginx/html /usr/share/nginx/html/1.1
