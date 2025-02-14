FROM ruby:3.1.4

WORKDIR /app

RUN apt-get update && apt-get install -y libsodium-dev

# Копируем Gemfile и устанавливаем зависимости
COPY Gemfile* ./
RUN gem install bundler && bundle install

# Копируем остальной исходный код
COPY . .

CMD ["ruby", "app/start_bot.rb"]
