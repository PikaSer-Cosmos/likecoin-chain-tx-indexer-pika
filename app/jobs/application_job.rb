class ApplicationJob < ActiveJob::Base
  # The extension must be included before other extensions
  include GoodJob::ActiveJobExtensions::InterruptErrors

  # Retry job ONCE if got error (could be network related)
  retry_on StandardError, wait: :polynomially_longer, attempts: 1
  # Retry the job if it is interrupted
  retry_on GoodJob::InterruptError, wait: 0, attempts: Float::INFINITY

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
