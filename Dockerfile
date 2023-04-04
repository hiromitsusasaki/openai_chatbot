FROM ruby:2.7

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

RUN apt-get update
RUN apt-get install -y \
    python3-pip \
    jq

RUN pip3 install awscli --upgrade --user
RUN pip3 install yq

RUN apt-get install -y awscli
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -\
    && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs \
    && apt-get upgrade -qq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*\
    && npm install -g yarn@1

RUN npm install -g serverless serverless-offline serverless-ruby-layer serverless-dynamodb-local

RUN gem install bundler

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

RUN sls config credentials --provider aws --key $AWS_ACCESS_KEY_ID --secret $AWS_SECRET_ACCESS_KEY
EXPOSE 3000
