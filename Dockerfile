# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.3
FROM public.ecr.aws/docker/library/ruby:$RUBY_VERSION-slim as base

# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ARG RUBYGEMS_VERSION="3.5.14"

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_USER_CACHE="/var/cache/bundle" \
    BUNDLE_GLOBAL_GEM_CACHE="true" \
    BUNDLE_WITHOUT="development"

RUN \
  gem update --system="$RUBYGEMS_VERSION" --no-document \
    && \
  gem --version

# We will keep downloaded packages in cache mounts, no need to cleanup
# See more at https://vsupalov.com/buildkit-cache-mount-dockerfile/
#
# `Binary::apt::APT::Keep-Downloaded-Packages "true"` is from
# https://github.com/docker/buildx/issues/549#issuecomment-1788297892
RUN \
  rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN \
  --mount=type=cache,id=apt-package-lists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
  --mount=type=cache,id=apt-cache-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
  apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config

# Install application gems
# Using mount instead of copying = one less layer
# Gemfile & Gemfile.lock are still copied later
RUN \
  --mount=type=cache,id=bundler-global-cache-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/bundle \
  --mount=target=. \
  MAKE="make --jobs $(nproc)" \
  bundle install --jobs="$(nproc)" && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# Final stage for app image
FROM base

# Install packages needed for deployment
# WITHOUT removing downloaded packages (saved in cache mount)
RUN \
  --mount=type=cache,id=apt-package-lists-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/lib/apt/lists \
  --mount=type=cache,id=apt-cache-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
  apt-get update -qq && \
  apt-get install --no-install-recommends -y  \
    curl \
    postgresql-client \
    libjemalloc2 \
  && \
  rm -rf /tmp/* /var/tmp/*

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p /tmp/pids && \
    chown -R rails:rails db log tmp /tmp/pids && \
    chmod 777 /tmp/pids
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
