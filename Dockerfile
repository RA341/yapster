# Environemnt to install flutter and build web
FROM debian:latest AS flutter_builder

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.24.0
ARG APP=/frontend/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY client $APP
# stup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean
RUN flutter pub get
RUN flutter build web --base-href=/static/


# Stage 2: Python FastAPI Server
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y ffmpeg && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .

RUN pip install -r requirements.txt && pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

COPY backend .

COPY --from=flutter_builder /frontend/build/web /app/static

ENV IN_DOCKER=0

EXPOSE 8000

CMD ["python", "main.py"]
