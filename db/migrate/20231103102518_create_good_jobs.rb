# frozen_string_literal: true

# AR migration require different stuff
# So the `good_job` generated migration is translated to `sequel` migration
# See bottom commented code for original generated code

Sequel.migration do
  change do
    create_table :good_jobs do
      column :id, "uuid", primary_key: true, default: Sequel.function(:gen_random_uuid), null: false

      column :queue_name, "text"
      column :priority, "integer"
      column :serialized_params, "jsonb"
      column :scheduled_at, "timestamp"
      column :performed_at, "timestamp"
      column :finished_at, "timestamp"
      column :error, "text"

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      column :active_job_id, "uuid"
      column :concurrency_key, "text"
      column :cron_key, "text"
      column :retried_good_job_id, "uuid"
      column :cron_at, "timestamp"

      column :batch_id, "uuid"
      column :batch_callback_id, "uuid"

      column :is_discrete, "boolean"
      column :executions_count, "integer"
      column :job_class, "text"
      column :error_event, "integer", limit: 2
    end

    create_table :good_job_batches do
      column :id, "uuid", primary_key: true, default: Sequel.function(:gen_random_uuid), null: false

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      column :description, "text"
      column :serialized_properties, "jsonb"
      column :on_finish, "text"
      column :on_success, "text"
      column :on_discard, "text"
      column :callback_queue_name, "text"
      column :callback_priority, "integer"
      column :enqueued_at, "timestamp"
      column :discarded_at, "timestamp"
      column :finished_at, "timestamp"
    end

    create_table :good_job_executions do
      column :id, "uuid", primary_key: true, default: Sequel.function(:gen_random_uuid), null: false

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      column :active_job_id, "uuid", null: false
      column :job_class, "text"
      column :queue_name, "text"
      column :serialized_params, "jsonb"
      column :scheduled_at, "timestamp"
      column :finished_at, "timestamp"
      column :error, "text"
      column :error_event, "integer", limit: 2
    end

    create_table :good_job_processes do
      column :id, "uuid", primary_key: true, default: Sequel.function(:gen_random_uuid), null: false

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      column :state, "jsonb"
    end

    create_table :good_job_settings do
      column :id, "uuid", primary_key: true, default: Sequel.function(:gen_random_uuid), null: false

      column :created_at, "timestamp"
      column :updated_at, "timestamp"

      column :key, "text"
      column :value, "jsonb"

      unique [:key]
    end

    add_index :good_jobs, :scheduled_at, where: "(finished_at IS NULL)", name: "index_good_jobs_on_scheduled_at"
    add_index :good_jobs, [:queue_name, :scheduled_at], where: "(finished_at IS NULL)", name: :index_good_jobs_on_queue_name_and_scheduled_at
    add_index :good_jobs, [:active_job_id, :created_at], name: :index_good_jobs_on_active_job_id_and_created_at
    add_index :good_jobs, :concurrency_key, where: "(finished_at IS NULL)", name: :index_good_jobs_on_concurrency_key_when_unfinished
    add_index :good_jobs, [:cron_key, :created_at], name: :index_good_jobs_on_cron_key_and_created_at
    add_index :good_jobs, [:cron_key, :cron_at], name: :index_good_jobs_on_cron_key_and_cron_at, unique: true
    # This is covered by `index_good_jobs_on_active_job_id_and_created_at` already
    # add_index :good_jobs, [:active_job_id], name: :index_good_jobs_on_active_job_id
    add_index :good_jobs, [:finished_at], where: "retried_good_job_id IS NULL AND finished_at IS NOT NULL", name: :index_good_jobs_jobs_on_finished_at
    add_index :good_jobs, [:priority, :created_at], order: { priority: "DESC NULLS LAST", created_at: :asc },
      where: "finished_at IS NULL", name: :index_good_jobs_jobs_on_priority_created_at_when_unfinished
    add_index :good_jobs, [:batch_id], where: "batch_id IS NOT NULL"
    add_index :good_jobs, [:batch_callback_id], where: "batch_callback_id IS NOT NULL"

    add_index :good_job_executions, [:active_job_id, :created_at], name: :index_good_job_executions_on_active_job_id_and_created_at
  end
end

# class CreateGoodJobs < ActiveRecord::Migration[7.1]
#   def change
#     # Uncomment for Postgres v12 or earlier to enable gen_random_uuid() support
#     # enable_extension 'pgcrypto'
#
#     create_table :good_jobs, id: :uuid do |t|
#       t.text :queue_name
#       t.integer :priority
#       t.jsonb :serialized_params
#       t.datetime :scheduled_at
#       t.datetime :performed_at
#       t.datetime :finished_at
#       t.text :error
#
#       t.timestamps
#
#       t.uuid :active_job_id
#       t.text :concurrency_key
#       t.text :cron_key
#       t.uuid :retried_good_job_id
#       t.datetime :cron_at
#
#       t.uuid :batch_id
#       t.uuid :batch_callback_id
#
#       t.boolean :is_discrete
#       t.integer :executions_count
#       t.text :job_class
#       t.integer :error_event, limit: 2
#     end
#
#     create_table :good_job_batches, id: :uuid do |t|
#       t.timestamps
#       t.text :description
#       t.jsonb :serialized_properties
#       t.text :on_finish
#       t.text :on_success
#       t.text :on_discard
#       t.text :callback_queue_name
#       t.integer :callback_priority
#       t.datetime :enqueued_at
#       t.datetime :discarded_at
#       t.datetime :finished_at
#     end
#
#     create_table :good_job_executions, id: :uuid do |t|
#       t.timestamps
#
#       t.uuid :active_job_id, null: false
#       t.text :job_class
#       t.text :queue_name
#       t.jsonb :serialized_params
#       t.datetime :scheduled_at
#       t.datetime :finished_at
#       t.text :error
#       t.integer :error_event, limit: 2
#     end
#
#     create_table :good_job_processes, id: :uuid do |t|
#       t.timestamps
#       t.jsonb :state
#     end
#
#     create_table :good_job_settings, id: :uuid do |t|
#       t.timestamps
#       t.text :key
#       t.jsonb :value
#       t.index :key, unique: true
#     end
#
#     add_index :good_jobs, :scheduled_at, where: "(finished_at IS NULL)", name: "index_good_jobs_on_scheduled_at"
#     add_index :good_jobs, [:queue_name, :scheduled_at], where: "(finished_at IS NULL)", name: :index_good_jobs_on_queue_name_and_scheduled_at
#     add_index :good_jobs, [:active_job_id, :created_at], name: :index_good_jobs_on_active_job_id_and_created_at
#     add_index :good_jobs, :concurrency_key, where: "(finished_at IS NULL)", name: :index_good_jobs_on_concurrency_key_when_unfinished
#     add_index :good_jobs, [:cron_key, :created_at], name: :index_good_jobs_on_cron_key_and_created_at
#     add_index :good_jobs, [:cron_key, :cron_at], name: :index_good_jobs_on_cron_key_and_cron_at, unique: true
#     add_index :good_jobs, [:active_job_id], name: :index_good_jobs_on_active_job_id
#     add_index :good_jobs, [:finished_at], where: "retried_good_job_id IS NULL AND finished_at IS NOT NULL", name: :index_good_jobs_jobs_on_finished_at
#     add_index :good_jobs, [:priority, :created_at], order: { priority: "DESC NULLS LAST", created_at: :asc },
#       where: "finished_at IS NULL", name: :index_good_jobs_jobs_on_priority_created_at_when_unfinished
#     add_index :good_jobs, [:batch_id], where: "batch_id IS NOT NULL"
#     add_index :good_jobs, [:batch_callback_id], where: "batch_callback_id IS NOT NULL"
#
#     add_index :good_job_executions, [:active_job_id, :created_at], name: :index_good_job_executions_on_active_job_id_and_created_at
#   end
# end
