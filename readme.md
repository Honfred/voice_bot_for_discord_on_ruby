# Мой бот для создания голосовых комнат в дискорде

Этот бот на Ruby позволяет создавать, 
редактировать и удалять голосовые каналы в Discord 
с помощью команды `!create_room`

---

## Запуск бота

Создать .env
```dotenv
DISCORD_BOT_TOKEN=ваш_токен_бота
DISCORD_CLIENT_ID=ваш_client_id
DISCORD_CATEGORY_ID=id_категории
```

Запустить контейнер
```bash
  make build
  make up
```

---

Остановить контейнер
```bash
  make stop
```

Перезапустить контейнер
```bash
  make restart
```

Посмотреть логи контейнера
```bash
  make logs
```

---

## Основные команды бота
Создание комнаты

```
!create_room <Название комнаты>
```

Редактирование комнаты
```
!edit_room <Прошлое название комнаты> <Новое название комнаты>
```

Если не находит прошлое название, то надо поставить # перед ним, например `#название`


Удаление происходит автоматически при выходе всех участников из канала