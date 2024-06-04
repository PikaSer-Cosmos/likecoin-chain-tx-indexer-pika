# frozen_string_literal: true

# AR migration require different stuff
# So the `good_job` generated migration is translated to `sequel` migration
# See bottom commented code for original generated code

Sequel.migration do
  # `no_transaction` required for `concurrently: true`
  no_transaction

  change do

    # region 07_recreate_good_job_cron_indexes_with_conditional

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/07_recreate_good_job_cron_indexes_with_conditional.rb.erb
    drop_index :good_jobs, [:cron_key, :created_at],
      name: :index_good_jobs_on_cron_key_and_created_at_cond, concurrently: true, if_exists: true
    drop_index :good_jobs, [:cron_key, :cron_at], unique: true,
      name: :index_good_jobs_on_cron_key_and_cron_at, concurrently: true, if_exists: true
    add_index :good_jobs, [:cron_key, :created_at], where: "(cron_key IS NOT NULL)",
      name: :index_good_jobs_on_cron_key_and_created_at_cond, concurrently: true, if_not_exists: true
    add_index :good_jobs, [:cron_key, :cron_at], where: "(cron_key IS NOT NULL)", unique: true,
      name: :index_good_jobs_on_cron_key_and_cron_at_cond, concurrently: true, if_not_exists: true

    # endregion 07_recreate_good_job_cron_indexes_with_conditional

    # region 08_create_good_job_labels

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/08_create_good_job_labels.rb.erb
    add_column :good_jobs, :labels, "text[]", if_not_exists: true

    # endregion 08_create_good_job_labels

    # region 09_create_good_job_labels_index

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/09_create_good_job_labels_index.rb.erb
    add_index :good_jobs, :labels, type: :gin, where: "(labels IS NOT NULL)",
      name: :index_good_jobs_on_labels, concurrently: true, if_not_exists: true

    # endregion 09_create_good_job_labels_index

    # region 10_remove_good_job_active_id_index

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/10_remove_good_job_active_id_index.rb.erb
    drop_index :good_jobs, :active_job_id,
      name: :index_good_jobs_on_active_job_id, concurrently: true, if_exists: true

    # endregion 10_remove_good_job_active_id_index

    # region 11_create_index_good_job_jobs_for_candidate_lookup

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/11_create_index_good_job_jobs_for_candidate_lookup.rb.erb
    add_index :good_jobs, [Sequel.asc(:priority, nulls: :last), Sequel.asc(:created_at)], where: "(finished_at IS NULL)",
      name: :index_good_job_jobs_for_candidate_lookup, concurrently: true, if_not_exists: true

    # endregion 11_create_index_good_job_jobs_for_candidate_lookup

    # region 12_create_good_job_execution_error_backtrace

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/12_create_good_job_execution_error_backtrace.rb.erb
    add_column :good_job_executions, :error_backtrace, "text[]", if_not_exists: true

    # endregion 12_create_good_job_execution_error_backtrace

    # region 13_create_good_job_process_lock_ids

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/13_create_good_job_process_lock_ids.rb.erb
    add_column :good_jobs, :locked_by_id, "uuid", if_not_exists: true
    add_column :good_jobs, :locked_at, "timestamp", if_not_exists: true
    add_column :good_job_executions, :process_id, "uuid", if_not_exists: true
    add_column :good_job_processes, :lock_type, "int2", if_not_exists: true

    # endregion 13_create_good_job_process_lock_ids

    # region 14_create_good_job_process_lock_indexes

    # https://github.com/bensheldon/good_job/blob/v3.29.2/lib/generators/good_job/templates/update/migrations/14_create_good_job_process_lock_indexes.rb.erb
    add_index :good_jobs, [Sequel.asc(:priority, nulls: :last), Sequel.asc(:scheduled_at)], where: "(finished_at IS NULL AND locked_by_id IS NULL)",
      name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked, concurrently: true, if_not_exists: true
    add_index :good_jobs, :locked_by_id, where: "(locked_by_id IS NOT NULL)",
      name: :index_good_jobs_on_locked_by_id, concurrently: true, if_not_exists: true
    add_index :good_job_executions, [:process_id, :created_at],
      name: :index_good_job_executions_on_process_id_and_created_at, concurrently: true, if_not_exists: true

    # endregion 14_create_good_job_process_lock_indexes

  end
end
