## setup testing and running
```bash
which ruby
export DB_HOST=localhost
export RAILS_ENV=test

bundle exec rails db:migrate
bundle exec rspec spec/requests/api/v1/authentication_spec.rb
```