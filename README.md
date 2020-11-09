# jiz4oh/rails-template

**jiz4oh/rails-template has supported the newest rails 6.0.0 project setup, forked from [dao42/rails-template](https://github.com/dao42/rails-template)**

Maybe the best & newest & fastest rails template for senior rails developer.

It maybe the best starting for your new rails project.

## Core Idea

`jiz4oh/rails-template` apply lots of good components for you to make development damn quick.

1. `jiz4oh/rails-template` keep the newest easily because it's a real `Rails Application Template`.
2. `jiz4oh/rails-template` love the newest standard components of Rails 6, using `webpacker` and remove `assets pipeline`.

## How to use

Install dependencies:

* postgresql

    ```bash
    $ brew install postgresql
    ```

    Ensure you have already initialized a user with username: `postgres` and password: `postgres`( e.g. using `$ createuser -d postgres` command creating one )

* rails 6

    Using `rbenv`, update `ruby` up to 2.5 or higher, and install `rails 6.0.0`

    ```bash
    $ ruby -v ( output should be 2.5.x or 2.6.x )

    $ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.com/` (optional, Chinese developer recommend)

    $ gem install rails

    $ rails -v ( output should be rails 6.0.0 )
    ```

* yarn

    Install `npm`, `yarn` for webpacker( see install document: https://yarnpkg.com/en/docs/install)

    ```bash
    $ yarn --version( output should be 1.6.x or higher )

    $ npm config set registry https://registry.npm.taobao.org (optional, Chinese developer recommend)
    ```

Then,

1. Add `gems.ruby-china.com` to your bundle mirrors (optional, Chinese developer recommended)

    `$ bundle config mirror.https://rubygems.org https://gems.ruby-china.com`

2. Create your own rails app applying `rails-template`

    `$ rails new myapp -m https://raw.githubusercontent.com/jiz4oh/rails-template/master/composer.rb`

    Important!! replace `myapp` to your real project name, we will generate lots of example files by this name.

3. Done! Trying to start it.

    `$ rails s`

## Integrated mainly technology stack and gems

* Ruby on Rails 6.0
* postgres
* figaro
* high_voltage
* redis
* sidekiq
* devise
* kaminari
* capistrano
* puma
* rspec
* annotate
* sentry3

## Starting with webpacker document

* [Starting with webpacker for Rails 6(zh-CN)](https://ruby-china.org/topics/38832)

## Deployment document

* [How to deploy to ubuntu 16.10 with rails-template step by step(zh-CN)](https://github.com/jiz4oh/rails-template/wiki/how-to-deploy-rails-to-ubuntu1404-with-rails-template)

* [x] Add AdminLTE as admin dashboard

## Projects that using `jiz4oh/rails-template`

Welcome to pull request here to update this if you choose `jiz4oh/rails-template` for your new rails app.

## LICENSE

MIT
