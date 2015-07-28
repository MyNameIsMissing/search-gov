source 'https://rubygems.org'

gem 'rake'
gem 'rails', "3.2.15"
gem 'mysql2', '>0.3'
gem 'capistrano'
gem 'curb'
gem 'haml'
gem 'json'
gem 'will_paginate'
gem 'nokogiri'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'authlogic'
gem 'airbrake'
gem 'yajl-ruby', :require => 'yajl'
gem 'redis'
gem 'redis-namespace'
gem 'resque'
gem 'resque-priority', :git => 'git://github.com/GSA/resque-priority.git'
gem 'resque-timeout'
gem 'resque-lock-timeout'
gem 'cloudfiles', '1.4.17'
gem 'cocaine', '~> 0.3.2'
gem 'paperclip-cloudfiles', :require => 'paperclip'
gem 'aws-s3', :require => 'aws/s3'
gem 'googlecharts'
gem 'sanitize'
gem 'tweetstream'
gem 'twitter'
gem 'flickraw'
gem 'bartt-ssl_requirement', :require => 'ssl_requirement'
gem 'active_scaffold'
gem 'active_scaffold_export'
gem 'us_states_select', :git => 'git://github.com/jeremydurham/us-state-select-plugin.git', :require => 'us_states_select'
gem 'mobile-fu'
gem 'rspec'
gem 'rspec-core'
gem 'cucumber'
gem "recaptcha", :require => "recaptcha/rails"
gem 'dynamic_form'
gem 'newrelic_rpm'
gem 'american_date'
gem 'sass'
gem "google_visualr"
gem 'oj'
gem 'faraday_middleware'
gem 'net-http-persistent'
gem 'rash'
gem 'geoip'
gem 'us_states'
gem 'htmlentities'
gem 'html_truncator'
gem 'addressable'
gem 'select2-rails'
gem 'turbolinks'
gem 'strong_parameters'
gem 'will_paginate-bootstrap'
gem 'virtus'
gem 'keen'
gem 'truncator'
gem 'em-http-request', '~> 1.0'
gem "validate_url"
gem 'elasticsearch'
gem 'federal_register'
gem 'github-markdown'
gem 'google-api-client'
gem 'instagram'
gem 'iso8601'
gem 'jbuilder'
gem 'rack-contrib'
gem 'sitelink_generator'
gem 'typhoeus'
gem 'mandrill-api'
gem 'activerecord-validate_unique_child_attribute', require: 'active_record/validate_unique_child_attribute'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails-bootstrap'
  # Wondering why all of the Font Awesome fonts aren't present? See
  # https://github.com/gsa/rails-font-awesome-grunticon for instructions
  # on how to add more icons to this gem
  gem 'rails-font-awesome-grunticon', git: 'git://github.com/gsa/rails-font-awesome-grunticon', ref: '2f43ad9cee4e4004e9cae4c015622006a92c2f5a'
  gem 'compass-rails'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'
  gem 'therubyracer'
  gem 'yui-compressor'
  gem 'twitter-typeahead-rails', '~> 0.11.1'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'webrat'
  gem 'rspec-rails'
  gem 'remarkable_activerecord'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'shoulda-matchers','~>1.4.0'
  gem 'capybara'
  gem 'launchy'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'thin'
  gem 'i18n-tasks', '~> 0.7.13'
  gem 'pry-byebug'
  gem 'rubocop'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'resque_spec'
  gem 'poltergeist'
end
