# OpenAI Chatbot API

## Description

OpenAI Chatbot API is a Web API for the Chatbot on Slack powered by GTP-3.5-Turbo.

## Setup

```zsh
cp .env.example .env
```
and set your OpenAI API key (and some credentials) to `.env` file.

## Usage

```zsh
docker compose up
```
then start serverless offline server at http://localhost:3000 and DynamoDB local and its admin console.

## deploy to AWS

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
