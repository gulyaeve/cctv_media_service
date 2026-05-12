FROM python:3.14

FROM bluenviron/mediamtx:1 AS mediamtx
FROM ghcr.io/astral-sh/uv:latest AS uv

COPY --from=mediamtx /mediamtx /

# add anything you need.
# RUN apt update && apt install -y \
#    gstreamer1.0-tools

RUN apt update && apt install -y \
    gcc g++ libpq-dev ffmpeg curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /uvx /bin/

# As volumes
# COPY ./mediamtx.yml /
# COPY ./ffmpeg_stream.py /ffmpeg_stream.py

WORKDIR /src

# Install dependencies
RUN --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen

# Place executables in the environment at the front of the path
ENV PATH="/src/.venv/bin:$PATH"


ENTRYPOINT [ "/mediamtx" ]