require 'discordrb'
require_relative 'room_manager'

class DiscordAPI
  attr_reader :bot

  def initialize(token, client_id)
    puts "Инициализация бота..."
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      client_id: client_id,
      prefix: '!'
    )
    setup_handlers
  end

  def run
    puts "Запуск бота..."
    @bot.run
  end

  private

  def setup_handlers
    @bot.ready do |_event|
      @room_manager = RoomManager.new(bot.servers.values.first) # Создаем менеджер комнат
      @room_manager.setup_event_handlers(bot) # Подключаем обработчик событий

      puts "\n=== Бот успешно подключился к Discord! ==="
      puts "Имя бота: #{@bot.profile.name}"
      puts "ID бота: #{@bot.profile.id}"
      puts "Количество серверов: #{@bot.servers.size}"
    end

    # Команда создания комнаты
    @bot.command(:create_room, description: 'Создаёт новую комнату (канал)') do |event, *args|
      room_name = args.join(" ")

      if room_name.empty?
        event.respond "Пожалуйста, укажите название комнаты. Пример: `!create_room НазваниеКомнаты`"
        next
      end

      room = @room_manager.create_room(room_name)

      if room
        event.respond "Комната **#{room.name}** успешно создана!"
      else
        event.respond "Ошибка при создании комнаты."
      end
    end

    # Команда редактирования названия комнаты
    @bot.command(:edit_room, description: 'Редактирует название указанного канала') do |event, channel_str, *new_name_parts|
      if channel_str.nil? || new_name_parts.empty?
        event.respond "Пожалуйста, укажите канал и новое название. Пример: `!edit_room #канал НовоеНазвание`"
        next
      end

      channel_id = parse_channel_id(channel_str, event)
      if channel_id.nil?
        event.respond "Не удалось определить ID канала из аргумента: #{channel_str}"
        next
      end

      channel = event.server.channels.find { |ch| ch.id == channel_id }
      if channel.nil?
        event.respond "Канал не найден."
      elsif !@room_manager.created_rooms.key?(channel.id)
        event.respond "Вы можете изменять только каналы, созданные этим ботом."
      else
        new_name = new_name_parts.join(" ")
        if @room_manager.edit_room(channel, new_name)
          event.respond "Название канала изменено на **#{new_name}**"
        else
          event.respond "Ошибка при изменении названия канала."
        end
      end
    end
  end

  # Метод для извлечения ID канала из строки.
  def parse_channel_id(channel_str, event)
    puts "DEBUG: Получен аргумент: #{channel_str}"

    # Если передали <#123456789> — извлекаем ID
    if channel_str =~ /^<#(\d+)>$/
      id = $1.to_i
      puts "DEBUG: Распознан ID из формата <#ID>: #{id}"
      return id
    end

    # Если передали просто ID (например, 123456789)
    if channel_str =~ /^\d+$/
      id = channel_str.to_i
      puts "DEBUG: Распознан ID напрямую: #{id}"
      return id
    end

    # Если передали #канал — убираем #
    if channel_str.start_with?("#")
      possible_name = channel_str[1..-1]
      puts "DEBUG: Распознано имя (с #): #{possible_name}"
    else
      possible_name = channel_str
      puts "DEBUG: Распознано имя (без #): #{possible_name}"
    end

    # Поиск канала по имени
    channel = event.server.channels.find { |ch| ch.name == possible_name }
    if channel
      puts "DEBUG: Найден канал по имени #{possible_name}: ID #{channel.id}"
      return channel.id
    else
      puts "DEBUG: Канал с именем #{possible_name} не найден!"
      return nil
    end
  end

end
