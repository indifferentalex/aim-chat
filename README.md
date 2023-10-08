![AIM Chat](aim-chat.png "AIM Chat (AI Messenger) Logo")

# AIM Chat

An (opinionated) Ruby on Rails app with `Chat` and `ChatMessage` models for
building chat applications integrating with the OpenAI ChatGPT API.

## Getting running

A Rails 7 app with all `rails new` defaults, if you're just trying it out and
have a RoR development environment set up you should be okay downloading the
repo, setting the `OPENAI_KEY` in .env, `bundle`ing, running migrations and
running `rails s`.

If you want to adjust anything to your liking (change databases, enable UUIDs,
update the config, etc.), do that before building out further, you shouldn't
run into any issues/conflicts.