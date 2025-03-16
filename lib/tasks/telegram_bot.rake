namespace :telegram do
  desc "Start the Telegram bot"
  task start: :environment do
    puts "Starting Telegram bot..."
    TelegramBotService.new.start
  end
end
