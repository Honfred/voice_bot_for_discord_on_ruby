$stdout.sync = true

require_relative 'discord_api'

token = ENV['DISCORD_BOT_TOKEN']
client_id = ENV['DISCORD_CLIENT_ID']

if token.nil? || client_id.nil?
  puts "Ошибка: Не установлены переменные окружения DISCORD_BOT_TOKEN и/или DISCORD_CLIENT_ID"
  exit(1)
end

puts "Запуск бота с client_id: #{client_id}"
api = DiscordAPI.new(token, client_id)
api.run
