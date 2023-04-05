# OpenAI Chatbot API

## Description

OpenAI Chatbot API is a Web API for the Chatbot on Slack powered by GTP-3.5-Turbo.

### Caution!
This code base is incomplete and immature. Please refer to the Todo section.

`conversation` function with GET API is for local operation checks and should not be deployed to the production environment

## Setup

```zsh
cp .env.example .env
```
and set your OpenAI API key (and some credentials) to `.env` file.

## Run local environment

```zsh
docker compose up
```
then start serverless offline server at http://localhost:3000 and DynamoDB local and its admin console.

## deploy to AWS （as Slack Chat Bot）

replace {bot id} to your slack bot id.

`handler.rb`
```
message = request_body['event']['text'].delete_prefix('{bot id} ')
```

```zsh
docker compose up
docker compose exec serverless sls deploy --stage prod

or

docker compose run --rm serverless sls deploy --stage prod
```

create Slack bot app on your workspace and set its credentials to environment variables

## Todo

- API requests from Slack are processed synchronously, so make processing asynchronous using jobs, etc., to return response codes earlier.

