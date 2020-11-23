FROM localhost:5000/python:3.8.5-buster as base
LABEL maintainer="Onna"

WORKDIR /app

RUN apt-get update && apt-get install -y vim netcat curl htop

# Utilizing poetry's install script sandboxes poetry's dependencies away from the system
# Otherwise applications may trample a package poetry requires, breaking poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - --version=1.0.9

# This is a bit of a hack ATM as $HOME is not set when docker is built
# This will need to be updated if we install poetry as a non-root user
ENV PATH="/root/.poetry/bin:$PATH"
RUN poetry config virtualenvs.create false

#########################
### Begin app install ###
#########################

# Install app dependencies
COPY pyproject.toml poetry.lock /app/
RUN poetry install --no-dev --no-root

# Install main app
COPY ./ /app
RUN poetry install --no-dev

#################

FROM base as test
RUN poetry install

#######################

FROM base as production
