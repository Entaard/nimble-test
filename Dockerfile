FROM ruby:2.6.5-slim

ARG BUILD_ENV=development
ARG RUBY_ENV=development
ARG NODE_ENV=development
ARG ASSET_HOST=http://localhost
# Set environment varaibles required in the initializers in order to precompile the assets.
# Because it initializes the app, so all variables need to exist in the build stage.
ARG MAILER_DEFAULT_HOST=http://localhost
ARG MAILER_DEFAULT_PORT=3000
ARG SECRET_KEY_BASE=secret_key_base

# Define all the envs here
ENV BUILD_ENV=$BUILD_ENV \
    RACK_ENV=$RUBY_ENV \
    RAILS_ENV=$RUBY_ENV \
    NODE_ENV=$NODE_ENV \
    ASSET_HOST=$ASSET_HOST \
    APP_HOME=/nimble_test \
    PORT=80 \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH="/bundle" \
    NODE_VERSION="12" \
    LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US:en"

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends apt-transport-https curl gnupg net-tools && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    apt-get install -y --no-install-recommends rsync locales chrpath pkg-config libfreetype6 libfontconfig1 git vim cmake wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Yarn repository
# Add the PPA (personal package archive) maintained by NodeSource
# This will have more up-to-date versions of Node.js than the official Debian repositories
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg && \
    echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_"$NODE_VERSION".x | bash - && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends nodejs yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install chrome and chromedriver for the crawler
# https://github.com/baozhida/docker-selenium-test/tree/master/nodechrome
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ARG CHROME_DRIVER_VERSION="latest"
RUN CD_VERSION=$(if [ ${CHROME_DRIVER_VERSION:-latest} = "latest" ]; then echo $(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE); else echo $CHROME_DRIVER_VERSION; fi) \
  && echo "Using chromedriver version: "$CD_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CD_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CD_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CD_VERSION /usr/bin/chromedriver

COPY generate-config /opt/bin/generate_config
RUN chmod 777 /opt/bin/generate_config

COPY chrome-launcher.sh /opt/google/chrome/google-chrome

# Generating a default config during build time
RUN /opt/bin/generate_config > /opt/selenium/config.json

# Put ChromeDriver into the PATH
#ENV PATH $CHROMEDRIVER_DIR:$PATH

WORKDIR $APP_HOME

# Skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
    echo '---'; \
    echo ':update_sources: true'; \
    echo ':benchmark: false'; \
    echo ':backtrace: true'; \
    echo ':verbose: true'; \
    echo 'gem: --no-ri --no-rdoc'; \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

# Install Ruby gems
RUN gem install bundler && \
    bundle config set jobs $BUNDLE_JOBS && \
    bundle config set path $BUNDLE_PATH && \
    if [ "$BUILD_ENV" = "production" ]; then \
      bundle config set deployment yes && \
      bundle config set without 'development test' ; \
    fi && \
    bundle install

# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --network-timeout 100000

# Copying the app files must be placed after the dependencies setup
# since the app files always change thus cannot be cached
COPY . ./

# Remove tmp/docker in the final image
RUN rm -rf tmp/docker

# Compile assets
RUN bundle exec rails i18n:js:export && \
    bundle exec rails assets:precompile

EXPOSE $PORT

CMD ./bin/start.sh
