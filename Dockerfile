FROM python:3.9.16-slim
ENV CLOUDSDK_PYTHON /usr/local/bin/python3
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PATH /root/.local/bin:$PATH

RUN apt-get -y update && \
    apt-get upgrade -qqy && \
    apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg && \
    pip3 install --upgrade pip setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies
COPY ./pyproject.toml /pyproject.toml
COPY ./poetry.lock /poetry.lock
RUN poetry config virtualenvs.create false && poetry install --only main

RUN mkdir -p /app
COPY ./app/ /app

ARG IMAGE_VERSION
ENV IMAGE_VERSION=${IMAGE_VERSION}

ARG SERVER_ADDRESS
ENV SERVER_ADDRESS=${SERVER_ADDRESS}

ARG BASE_URL_PATH
ENV BASE_URL_PATH=${BASE_URL_PATH}

CMD poetry run streamlit run /app/entrypoint.py \
    --browser.serverAddress="${SERVER_ADDRESS}" \
    --server.port=8080 \
    --server.baseUrlPath="${BASE_URL_PATH}" \
    --server.fileWatcherType="poll" \
    --browser.gatherUsageStats=False
