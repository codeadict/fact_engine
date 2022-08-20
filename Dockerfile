FROM elixir:1.13-alpine AS builder

RUN apk add --no-cache git openssh-client

WORKDIR /tmp/fact_engine

ADD mix.exs .
ADD mix.lock .

RUN mix local.hex --force && \
  mix local.rebar --force && \
  MIX_ENV=prod mix deps.get && \
  MIX_ENV=prod mix deps.compile


COPY config ./config
COPY src ./src
COPY lib ./lib


RUN MIX_ENV=prod mix escript.build

FROM erlang:24-alpine

# copy the generated escript binary over here
COPY --from=builder /tmp/fact_engine/fact_engine ./

CMD [ "/fact_engine" ]
