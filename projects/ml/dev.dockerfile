FROM python:3.6.4

LABEL name="margaret_ml_dev"
LABEL version="1.0.0"
LABEL maintainer="strattadb@gmail.com"

ENV PYTHONUNBUFFERED=1
ENV SHELL=/bin/bash

RUN pip install pipenv

# Create and change current directory.
WORKDIR /usr/src/app

# Install dependencies.
COPY Pipfile Pipfile.lock ./
# RUN pipenv install && \
#     # Activate the virtualenv. It doesn't work with `pipenv shell`
#     # so we do it the old way.
#     source "$(pipenv --venv)/bin/activate"

# Bundle app source.
COPY . .

CMD ["tail", "-f", "/dev/null"]
