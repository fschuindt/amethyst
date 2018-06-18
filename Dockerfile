# -----------------------------------------------------------------
# Build
# -----------------------------------------------------------------
FROM elixir:1.6.5-alpine as build

COPY . .

RUN apk add --no-cache git

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix release

RUN mkdir /export && \
    export REL=`ls -d _build/prod/rel/amethyst/releases/*/` && \
    tar -xzf "$REL/amethyst.tar.gz" -C /export

# -----------------------------------------------------------------
# "Deploy"
# -----------------------------------------------------------------
FROM erlang:20-alpine

COPY --from=build /export/ .

RUN apk add --no-cache bash

EXPOSE 7171

CMD bin/amethyst foreground
