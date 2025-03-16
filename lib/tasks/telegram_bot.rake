namespace :telegram do
  desc "Start the Telegram bot"
  task start: :environment do
    TelegramBotService.start
  end
end
