FROM fluent/fluentd-kubernetes-daemonset:v1.2-debian-logzio

USER root
WORKDIR /home/fluent

COPY Gemfile* /fluentd/
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps libjemalloc1 ruby-bundler \
 && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

# Copy configuration files
COPY ./conf/fluent.conf /fluentd/etc/
COPY ./conf/systemd.conf /fluentd/etc/
COPY ./conf/kubernetes.conf /fluentd/etc/
