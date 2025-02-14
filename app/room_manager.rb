class RoomManager
  attr_reader :created_rooms

  def initialize(server)
    @server = server
    @created_rooms = {}
    @category_id = ENV['DISCORD_CATEGORY_ID']
  end

  # Создает текстовый канал с заданным именем.
  # Если @category_id задан, канал будет создан в этой категории.
  def create_room(name)
    begin
      options = {}
      if @category_id && !@category_id.empty?
        options[:parent] = @category_id.to_i
        puts "Создаю канал в категории с ID: #{@category_id}"
      else
        puts "Создаю канал без категории"
      end

      # Для текстового канала - 0, для голосового - 2
      channel = @server.create_channel(name, 2, **options)
      if channel.nil?
        puts "Метод create_channel вернул nil"
      else
        @created_rooms[channel.id] = channel
        puts "Канал создан: #{channel.name} (ID: #{channel.id})"
      end
      channel
    rescue StandardError => e
      puts "Ошибка при создании комнаты: #{e.message}"
      nil
    end
  end

  def edit_room(channel, new_name)
    unless @created_rooms.key?(channel.id)
      puts "Попытка изменить канал, который не был создан ботом: #{channel.id}"
      return false
    end

    begin
      channel.name = new_name
      @created_rooms[channel.id] = new_name
      true
    rescue StandardError => e
      puts "Ошибка при изменении названия комнаты: #{e.message}"
      false
    end
  end

  # Обработчик событий созданных комнат
  def setup_event_handlers(bot)
    bot.voice_state_update do |event|
      old_channel = event.old_channel
      new_channel = event.channel

      puts "Обновление голосового состояния: #{event.user.name} (из: #{old_channel&.name || 'nil'} -> в: #{new_channel&.name || 'nil'})"

      if old_channel
        sleep 1
        check_and_delete_empty_room(old_channel)
      end
    end
  end


  private

  def check_and_delete_empty_room(channel)
    puts "channel #{channel}"
    return unless channel
    puts "@created_rooms.key  #{@created_rooms.key?(channel.id)}"
    return unless @created_rooms.key?(channel.id)

    puts "Проверяем канал #{channel.name} на пустоту..."

    actual_users = @server.voice_states.values.select { |vs| vs.channel == channel }.map(&:user)

    if actual_users.empty?
      puts "Удаляем пустой голосовой канал: #{channel.name} (ID: #{channel.id})"
      @created_rooms.delete(channel.id)
      channel.delete
    else
      puts "Канал #{channel.name} не пуст. Количество пользователей: #{actual_users.count}"
    end
  end
end
