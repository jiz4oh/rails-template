# myapp
The source code of myapp

## Installation

Install dependencies:

* postgresql

    ```bash
    $ brew install postgresql
    ```

    Ensure you have already initialized a user with username: `postgres` and password: `postgres`( e.g. using `$ createuser -d postgres` command creating one )

* rails 6

    Using `rvm`, update `ruby` up to 2.5 or higher, and install `rails 6.0.0`

    ```bash
    $ ruby -v ( output should be 2.5.x or higher )

    $ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.com/` (optional, Chinese developer recommend)

    $ gem install rails

    $ rails -v ( output should be rails 6.0.0 or higher )
    ```

* yarn

    Install `yarn` for webpacker( see install document: https://yarnpkg.com/en/docs/install)

    ```bash
    $ yarn --version( output should be 1.6.x or higher )
    ```
Then,

```bash
$ ./bin/setup
$ ./bin/webpack-dev-server
# open new terminal tab
$ rails s
```

## Admin dashboard info

Access url: /admin

Default superuser: admin

Default password: admin

## Tech stack

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
* sentry

## Built with

[jiz4oh/rails-template](https://github.com/jiz4oh/rails-template)

## LICENSE

MIT
