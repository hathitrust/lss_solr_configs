# The base layer will contain the dependencies shared by the other layers
FROM python:3.11-slim-bookworm AS base

# Allowing the argumenets to be read into the dockerfile. Ex:  .env > compose.yml > Dockerfile
ARG POETRY_VERSION=1.5.1
# ENV=dev => development / ENV=prod => production
ARG ENV

# Set the working directory to /app
WORKDIR /solr_manager

# Use this page as a reference for python and poetry environment variables: https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED
# Ensure the stdout and stderr streams are sent straight to terminal, then you can see the output of your application
ENV PYTHONUNBUFFERED=1\
  # Avoid the generation of .pyc files during package install
  # Disable pip's cache, then reduce the size of the image
  PIP_NO_CACHE_DIR=off \
  # Save runtime because it is not look for updating pip version
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  # Disable poetry interaction
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=1 \
  POETRY_VIRTUALENVS_IN_PROJECT=1 \
  POETRY_CACHE_DIR=/tmp/poetry_cache

RUN pip install poetry==${POETRY_VERSION}

# Install the app. Just copy the files needed to install the dependencies
COPY pyproject.toml poetry.lock README.md ./

# Poetry cache is used to avoid installing the dependencies every time the code changes, we will keep this folder in development environment and remove it in production
# --no-root, poetry will install only the dependencies avoiding to install the project itself, we will install the project in the final layer
# --without dev to avoid installing dev dependencies, we do not need test and linters in production environment
# --with dev to install dev dependencies, we need test and linters in development environment
# --mount, mount a folder for plugins with poetry cache, this will speed up the process of building the image
RUN if [ {${ENV}="dev"} ]; then \
  echo "Installing dev dependencies"; \
  poetry install --no-root --with dev \
  else \
  echo "Skipping dev dependencies"; \
  poetry install --no-root --without dev && rm -rf ${POETRY_CACHE_DIR}; \
  fi

# Set up our final runtime layer
FROM python:3.11-slim-bookworm AS runtime

ENV FASTAPI_ENV=runtime

ARG UID=1000
ARG GID=1000

# Create our users here in the last layer or else it will be lost in the previous discarded layers
# Create a system group named "app_user" with the -r flag
RUN groupadd -g ${GID} -o solr_manager
RUN useradd -m -d /solr_manager -u ${UID} -g ${GID} -o -s /bin/bash solr_manager
RUN mkdir -p /venv && chown ${UID}:${GID} /venv
RUN which pip && sleep 10

# By adding /venv/bin to the PATH the dependencies in the virtual environment
# are used
ENV VIRTUAL_ENV=/venv \
  PATH="/venv/bin:$PATH"

COPY --chown=${UID}:${GID} --from=base "/solr_manager/.venv" ${VIRTUAL_ENV}

# Switch to the non-root user "user"
USER solr_manager

WORKDIR /solr_manager

ENV PYTHONPATH=/solr_manager

COPY --chown=${UID}:${GID} . /solr_manager

CMD ["tail", "-f", "/dev/null"]
