# # Use an official Elixir runtime as a parent image
# FROM elixir:latest

FROM elixir:1.9 

# install build dependencies
RUN apt-get update && \
    apt-get install -y postgresql-client

RUN apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -y nodejs \
    && curl -L https://www.npmjs.com/install.sh | sh

RUN mkdir /app
COPY . /app
WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=dev

# install mix dependencies

RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile


# build assets

RUN cd assets && npm install 
RUN mix phx.digest

# build project

RUN mix compile


# build release
# at this point we should copy the rel directory but
# we are not using it so we can omit it
# COPY rel rel
ENTRYPOINT [ "/app/entrypoint.sh"]

# prepare release image
