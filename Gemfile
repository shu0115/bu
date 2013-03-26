source 'http://rubygems.org'

# hack to make heroku cedar not install special groups
# http://soupmatt.com/fixing-bundlewithout-on-heroku-cedar

def hg(g)
  (ENV['HOME'].gsub('/','') == 'app' ? :test : g)
end

gem 'rails', '3.2.13'

group :preview do
  gem 'pg'
  gem 'thin'
end

group :assets do
  gem 'sass-rails',   '~> 3.2.1'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'configatron'
gem 'jquery-rails'
gem 'haml-rails'
gem 'execjs'
gem 'hikidoc'

gem 'omniauth'
gem 'omniauth-twitter'
gem 'authentication'

group hg(:production) do
  gem 'sqlite3'
end

group :test, :development do
  gem 'sqlite3'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rails_best_practices', '>= 1.2.0', :require => false
  gem 'database_cleaner'
  gem 'forgery'
  gem 'pry-rails'
  gem 'pry-nav'
#  gem 'pry-coolline'  # 2013/03/18 bundle installエラー：「An error occurred while installing io-console (0.3), and Bundler cannot continue.」
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', :git => 'git://github.com/thoughtbot/shoulda-matchers.git', :ref => 'fd4aa5'
  #gem 'rails-erd'

  gem 'sextant'  # /rails/routes
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'tapp'
  gem 'awesome_print'
  gem 'coveralls', require: false
end

# Utility
gem 'action_args'
gem 'html5_validators'

# Translation
gem 'i18n_generators'

# Exception Error Notice
gem 'exception_notification'
