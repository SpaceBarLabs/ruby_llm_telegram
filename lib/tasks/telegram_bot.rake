namespace :telegram do
  desc "Start the Telegram bot"
  task start: :environment do
    # Configure Rails logger to output to STDOUT with debug level
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    # Add timestamp and log level to the format
    Rails.logger.formatter = proc do |severity, datetime, _progname, msg|
      date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
      "[#{date_format}] #{severity}: #{msg}\n"
    end

    Rails.logger.info("Logger configured for console output")
    TelegramBotService.new.start
  end
end
