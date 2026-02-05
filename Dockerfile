FROM ruby:3.2.2-alpine AS build-env
ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git libcurl nodejs-current yarn "
ARG DEV_PACKAGES="yaml-dev zlib-dev mariadb-dev vips-dev"
ARG RUBY_PACKAGES="tzdata shared-mime-info"
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development"

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY



# install packages
RUN apk update \
    && apk upgrade --ignore alpine-baselayout \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

# install rubygem
COPY Gemfile Gemfile.lock $RAILS_ROOT/
RUN gem install bundler -v 2.3.20

RUN bundle config --global frozen 1

ARG IMAGE_ENV=production
ARG ARG_BUNDLE_GITHUB__COM
ENV BUNDLE_GITHUB__COM=$ARG_BUNDLE_GITHUB__COM


RUN if [ "x$IMAGE_ENV" = "x" ] ; then bundle install -j4 --retry 3 --path=vendor/bundle ; fi
RUN if [ "$IMAGE_ENV" = "development" ] ; then bundle install -j4 --retry 3 --path=vendor/bundle ; fi
RUN if [ "$IMAGE_ENV" = "production" ] ; then bundle install --without development:test:assets -j4 --retry 3 --path=vendor/bundle ; fi

COPY . .

RUN if [ "$IMAGE_ENV" = "production" ] ; then bundle exec rake assets:precompile avo:build-assets ; fi

RUN rm -rf vendor/bundle/ruby/3.*.*/cache/*.gem \
    && find vendor/bundle/ruby/3.*.*/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/3.*.*/gems/ -name "*.o" -delete



RUN if [ "$IMAGE_ENV" = "production" ] ; then rm -rf node_modules tmp/cache vendor/assets lib/assets spec ; fi

############### Build step done ###############
FROM ruby:3.2.2-alpine
ARG RAILS_ROOT=/app
ARG PACKAGES="mariadb-connector-c-dev tzdata mysql-client bash libcurl vips-dev less curl"

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade --ignore alpine-baselayout \
    && apk add --update --no-cache $PACKAGES
COPY --from=build-env $RAILS_ROOT $RAILS_ROOT
RUN bundle exec rails -e "p 1"

RUN gem install bundler -v 2.3.20

RUN echo 'alias berc="bundle exec rails c"' >> ~/.bashrc
RUN echo 'alias be="bundle exec"' >> ~/.bashrc





# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]

