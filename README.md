# OpenAI Chatbot API

## Description

OpenAI Chatbot API is a RESTful API for the Chatbot powered by GTP-3.5-Turbo.

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

```zsh
docker compose up
docker compose exec serverless sls deploy --stage prod

or

docker compose run --rm serverless sls deploy --stage prod
```
