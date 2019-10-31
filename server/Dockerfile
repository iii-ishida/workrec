FROM elixir:1.9.0-alpine as build

RUN apk add --update git build-base nodejs yarn python

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

# Set mix env and ports
ENV MIX_ENV=prod
ARG SECRET_KEY_BASE

# Cache elixir deps
COPY mix.exs mix.lock ./
COPY config config 
RUN  mix do deps.get, deps.compile

ARG CLIENT_ORIGIN
COPY priv priv
COPY lib lib
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/workrec ./
RUN chown -R nobody: /app
USER nobody

CMD ["./bin/workrec", "start"]
