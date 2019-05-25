# Use the official Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:2.6.3-slim

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN apt-get update \
  && apt-get install -y --no-install-recommends make gcc libc-dev \
  && bundle install --without test development --path=vendor/bundle \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Copy local code to the container image.
COPY . .

# Run the web service on container startup.
ENV RACK_ENV=production
CMD ["bundle", "exec", "rackup", "-p", "8080"]
