# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

rails_env = ENV.fetch("RAILS_ENV", "development")

#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

if rails_env == "production"
  # If you are running more than 1 thread per process, the workers count
  # should be equal to the number of processors (CPU cores) in production.
  #
  # It defaults to 1 because it's impossible to reliably detect how many
  # CPU cores are available. Make sure to set the `WEB_CONCURRENCY` environment
  # variable to match the number of processors.
  require "concurrent-ruby"
  require "concurrent/utility/processor_counter"
  workers_count = Integer(ENV.fetch("WEB_CONCURRENCY") { ::Concurrent.available_processor_count })
  workers workers_count if workers_count > 1

  preload_app!
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Specifies the `environment` that Puma will run in.
environment rails_env

# region Fork-Worker Cluster Mode

# Puma 5 introduces an experimental new cluster-mode configuration option, fork_worker (--fork-worker from the CLI).
# This mode causes Puma to fork additional workers from worker 0, instead of directly from the master process
# https://github.com/puma/puma/blob/master/docs/fork_worker.md
mold_worker(400, 800, 1600, 3200)

on_mold_promotion do
  # Run GC before forking
  3.times {GC.start}
end

# endregion Fork-Worker Cluster Mode

# region Out of Band Garbage Collection

# Available since 3.4
oobgc_available = GC.respond_to?(:config)
if oobgc_available
  on_worker_boot do
    GC.config(rgengc_allow_full_mark: false)
  end

  out_of_band do
    if GC.latest_gc_info(:need_major_by)
      GC.start
    end
  end
end

# endregion Out of Band Garbage Collection

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

if rails_env == "development"
  # Specifies a very generous `worker_timeout` so that the worker
  # isn't killed by Puma when suspended by a debugger.
  worker_timeout 3600
end

# region YJIT runtime stats

# Can't use `ENV!`
if defined?(RubyVM::YJIT.enable) &&
  ENV["RUBY_YJIT_STATS_ENABLED"] == "true"

  out_of_band do
    yjit_runtime_stats = RubyVM::YJIT.runtime_stats
    next if yjit_runtime_stats.nil?

    puts("========== YJIT Runtime Stats ==========")
    puts(yjit_runtime_stats.slice(:ratio_in_yjit))
    puts("========== YJIT Runtime Stats ==========")
  end
end

# endregion YJIT runtime stats
