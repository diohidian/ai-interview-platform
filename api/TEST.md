## setup testing and running
```bash
which ruby
export DB_HOST=localhost
export RAILS_ENV=test

bundle exec rspec spec/requests/api/v1/authentication_spec.rb
bundle exec rspec spec/requests/api/v1/vacancies_spec.rb
bundle exec rspec spec/requests/api/v1/assessments_spec.rb
```