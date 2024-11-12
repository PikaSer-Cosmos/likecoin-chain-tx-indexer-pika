require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# Required to be loaded for `marginalia`
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
if %w[development test].include? ENV['RAILS_ENV']
  Dotenv::Railtie.load
end

module LikecoinChainTxIndexerPika
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    log_level = (
      [
        (ENV["LOG_LEVEL"] ||
          ::Rails.application.config.log_level).to_s.upcase,
        "INFO",
      ] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]
    ).compact.first
    config.log_level = log_level

    # region sequel

    # Allowed options: :sql, :ruby.
    config.sequel.schema_format = :sql

    # Configure whether database's rake tasks will be loaded or not.
    #
    # If passed a String or Symbol, this will replace the `db:` namespace for
    # the database's Rake tasks.
    #
    # ex: config.sequel.load_database_tasks = :sequel
    #     will results in `rake db:migrate` to become `rake sequel:migrate`
    #
    # Defaults to true
    # config.sequel.load_database_tasks = false
    config.sequel.load_database_tasks = :sq

    # This setting disabled the automatic connect after Rails init
    # Necessary check https://github.com/TalentBox/sequel-rails/issues/193
    # if defined?(Rake.application)
    #   config.sequel.skip_connect = true
    # end

    # Configure if Sequel should try to 'test' the database connection in order
    # to fail early
    config.sequel.test_connect = true

    config.sequel.after_connect = proc do
      # `update_on_create = true`: Set `updated_at` on record creation
      Sequel::Model.plugin :timestamps, update_on_create: true
      Sequel::Model.plugin :update_or_create
      Sequel::Model.plugin :dirty
      # Project local plugin, see `lib/sequel/plugins/global_id.rb`
      Sequel::Model.plugin :global_id
      # database specific extension
      Sequel::Model.db.extension(
        :pg_array,
        :pg_json,
        :batches,
      )
      Sequel.extension :pg_json_ops
      Sequel.extension :pg_array_ops
      Sequel.extension :named_timezones
      Sequel.database_timezone = :utc
      # Sequel.extension :pg_hstore_ops # sequel specific extension
    end

    # endregion sequel

    config.active_job.queue_adapter = :good_job
    config.active_job.queue_name_delimiter = '.'
    config.active_job.queue_name_prefix = Rails.env
    config.good_job = {
      # There is no way to only preserve job records for some types
      # And there are plenty of NFT related jobs
      # No point for a small app with small DB to use most space on job records
      preserve_job_records: :on_unhandled_error,
      retry_on_unhandled_error: false,
      on_thread_error: -> (exception) { Rails.error.report(exception) },
      execution_mode: :external,
      # Why care about active job priority description
      # Also the generated migration got index  with order `priority: "DESC NULLS LAST"`
      smaller_number_is_higher_priority: true,
      dashboard_default_locale: :en,
    }
  end
end
