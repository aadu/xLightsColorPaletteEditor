FROM nginx:mainline

ENV NPM_CONFIG_LOGLEVEL='info' \
    NODE_VERSION='14.16.0' 

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
    openssh-client \
    git \
    curl \
    bzip2 \
    xz-utils \
    ca-certificates \
    g++ \
    build-essential \
    python3 \
	&& apt-get -y --purge autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
	&& tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.xz" \
	&& ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install -g yarn
RUN yarn global add @vue/cli
RUN yarn global add typescript

# CLIENT
COPY package.json /code/
WORKDIR /code
RUN yarn

COPY . /code
RUN yarn build
# production server
CMD yarn start
EXPOSE 8080 3000 80 443
