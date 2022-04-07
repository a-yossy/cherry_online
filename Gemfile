source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '6.1.4.1'

gem 'active_storage_validations'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'coderay'
gem 'devise'
gem 'dotenv-rails'
gem 'haml-rails'
gem 'image_processing'
gem 'jbuilder'
gem 'kaminari'
gem 'pg'
gem 'pre-commit'
gem 'puma'
gem 'ranked-model'
gem 'ransack'
gem 'redcarpet'
gem 'sass-rails'
gem 'sgcop', github: 'SonicGarden/sgcop'
gem 'turbolinks'
# 手動でversionを上げる
gem 'webpacker', '5.4.3'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'bullet'
  gem 'letter_opener_web'
  gem 'listen'
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webdrivers'
end
