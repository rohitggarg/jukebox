source 'http://rubygems.org'

gem 'rails', '~> 4.2'
gem 'resque'
gem 'airbrake', '~> 5.0'

group :development do
  gem 'sqlite3'
  gem 'duktape'
end
group :development, :test do
  gem 'byebug'
  gem 'rspec'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
group :production do
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3'
  gem 'coffee-rails', '~> 4.1'
  gem 'tzinfo-data', platforms: :x64_mingw
  gem 'jquery-rails'
  gem 'turbolinks'
  gem 'jbuilder', '~> 2.0'
  gem 'pg'
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4', group: :doc
end

