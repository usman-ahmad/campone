# This migration combines six migration from acts_as_taggable_on (originally 1..6)
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    ########## acts_as_taggable_on_migration.acts_as_taggable_on_engine ##########
    create_table :tags do |t|
      t.string :name
    end

    create_table :taggings do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]

    ########## add_missing_unique_indices.acts_as_taggable_on_engine ##########
    add_index :tags, :name, unique: true

    remove_index :taggings, :tag_id if index_exists?(:taggings, :tag_id)
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx'

    ########## add_taggings_counter_cache_to_tags.acts_as_taggable_on_engine ##########
    add_column :tags, :taggings_count, :integer, default: 0

    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end

    ########## add_missing_taggable_index.acts_as_taggable_on_engine ##########
    add_index :taggings, [:taggable_id, :taggable_type, :context]


    ########## change_collation_for_tag_names.acts_as_taggable_on_engine ##########
    if ActsAsTaggableOn::Utils.using_mysql?
      execute("ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
    end


    ########## add_missing_indexes.acts_as_taggable_on_engine ##########
    add_index :taggings, :tag_id
    add_index :taggings, :taggable_id
    add_index :taggings, :taggable_type
    add_index :taggings, :tagger_id
    add_index :taggings, :context

    add_index :taggings, [:tagger_id, :tagger_type]
    add_index :taggings, [:taggable_id, :taggable_type, :tagger_id, :context], name: 'taggings_idy'

  end

  def self.down
    ########## add_missing_indexes.acts_as_taggable_on_engine ##########
    remove_index :taggings, name: 'taggings_idy'
    remove_index :taggings, [:tagger_id, :tagger_type]
    remove_index :taggings, :context
    remove_index :taggings, :tagger_id
    remove_index :taggings, :taggable_type
    remove_index :taggings, :taggable_id
    remove_index :taggings, :tag_id

    ########## add_missing_taggable_index.acts_as_taggable_on_engine ##########
    remove_index :taggings, [:taggable_id, :taggable_type, :context]

    ########## add_taggings_counter_cache_to_tags.acts_as_taggable_on_engine ##########
    remove_column :tags, :taggings_count

    ########## add_missing_unique_indices.acts_as_taggable_on_engine ##########
    add_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings, :tag_id unless index_exists?(:taggings, :tag_id)
    remove_index :taggings, name: 'taggings_idx'
    remove_index :tags, :name

    ########## acts_as_taggable_on_migration.acts_as_taggable_on_engine ##########
    drop_table :taggings
    drop_table :tags
  end
end

# # This migration comes from acts_as_taggable_on_engine (originally 1)
# class ActsAsTaggableOnMigration < ActiveRecord::Migration
#   def self.up
#     create_table :tags do |t|
#       t.string :name
#     end
#
#     create_table :taggings do |t|
#       t.references :tag
#
#       # You should make sure that the column created is
#       # long enough to store the required class names.
#       t.references :taggable, polymorphic: true
#       t.references :tagger, polymorphic: true
#
#       # Limit is created to prevent MySQL error on index
#       # length for MyISAM table type: http://bit.ly/vgW2Ql
#       t.string :context, limit: 128
#
#       t.datetime :created_at
#     end
#
#     add_index :taggings, :tag_id
#     add_index :taggings, [:taggable_id, :taggable_type, :context]
#   end
#
#   def self.down
#     drop_table :taggings
#     drop_table :tags
#   end
# end
#
# # This migration comes from acts_as_taggable_on_engine (originally 2)
# class AddMissingUniqueIndices < ActiveRecord::Migration
#   def self.up
#     add_index :tags, :name, unique: true
#
#     remove_index :taggings, :tag_id if index_exists?(:taggings, :tag_id)
#     remove_index :taggings, [:taggable_id, :taggable_type, :context]
#     add_index :taggings,
#               [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
#               unique: true, name: 'taggings_idx'
#   end
#
#   def self.down
#     remove_index :tags, :name
#
#     remove_index :taggings, name: 'taggings_idx'
#
#     add_index :taggings, :tag_id unless index_exists?(:taggings, :tag_id)
#     add_index :taggings, [:taggable_id, :taggable_type, :context]
#   end
# end
#
# # This migration comes from acts_as_taggable_on_engine (originally 3)
# class AddTaggingsCounterCacheToTags < ActiveRecord::Migration
#   def self.up
#     add_column :tags, :taggings_count, :integer, default: 0
#
#     ActsAsTaggableOn::Tag.reset_column_information
#     ActsAsTaggableOn::Tag.find_each do |tag|
#       ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
#     end
#   end
#
#   def self.down
#     remove_column :tags, :taggings_count
#   end
# end
#
# # This migration comes from acts_as_taggable_on_engine (originally 4)
# class AddMissingTaggableIndex < ActiveRecord::Migration
#   def self.up
#     add_index :taggings, [:taggable_id, :taggable_type, :context]
#   end
#
#   def self.down
#     remove_index :taggings, [:taggable_id, :taggable_type, :context]
#   end
# end
#
# # This migration comes from acts_as_taggable_on_engine (originally 5)
# # This migration is added to circumvent issue #623 and have special characters
# # work properly
# class ChangeCollationForTagNames < ActiveRecord::Migration
#   def up
#     if ActsAsTaggableOn::Utils.using_mysql?
#       execute("ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
#     end
#   end
# end
#
# # This migration comes from acts_as_taggable_on_engine (originally 6)
# class AddMissingIndexes < ActiveRecord::Migration
#   def change
#     add_index :taggings, :tag_id
#     add_index :taggings, :taggable_id
#     add_index :taggings, :taggable_type
#     add_index :taggings, :tagger_id
#     add_index :taggings, :context
#
#     add_index :taggings, [:tagger_id, :tagger_type]
#     add_index :taggings, [:taggable_id, :taggable_type, :tagger_id, :context], name: 'taggings_idy'
#   end
# end
#
#
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
# UP UP UP UP UP UP UP UP UP UP UP UP UP UP UP UP
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
#
# ➜  camp_one git:(g3_tags) ✗ bin/rails db:migrate RAILS_ENV=development
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054639 ActsAsTaggableOnMigration: migrating ========================
# -- create_table(:tags, {})
#    -> 0.0144s
# -- create_table(:taggings, {})
#    -> 0.0061s
# -- add_index(:taggings, :tag_id)
#    -> 0.0044s
# -- add_index(:taggings, [:taggable_id, :taggable_type, :context])
#    -> 0.0053s
# == 20161227054639 ActsAsTaggableOnMigration: migrated (0.0308s) ===============
#
# == 20161227054640 AddMissingUniqueIndices: migrating ==========================
# -- add_index(:tags, :name, {:unique=>true})
#    -> 0.0044s
# -- index_name(:taggings, {:column=>["tag_id"]})
#    -> 0.0000s
# -- index_exists?(:taggings, :tag_id, {:name=>"index_taggings_on_tag_id"})
#    -> 0.0061s
# -- index_name(:taggings, {:column=>:tag_id})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_tag_id", true)
#    -> 0.0016s
# -- remove_index(:taggings, {:column=>:tag_id, :name=>"index_taggings_on_tag_id"})
#    -> 0.0061s
# -- index_name(:taggings, {:column=>[:taggable_id, :taggable_type, :context]})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_taggable_id_and_taggable_type_and_context", true)
#    -> 0.0017s
# -- remove_index(:taggings, {:column=>[:taggable_id, :taggable_type, :context], :name=>"index_taggings_on_taggable_id_and_taggable_type_and_context"})
#    -> 0.0053s
# -- add_index(:taggings, [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type], {:unique=>true, :name=>"taggings_idx"})
#    -> 0.0041s
# == 20161227054640 AddMissingUniqueIndices: migrated (0.0304s) =================
#
# == 20161227054641 AddTaggingsCounterCacheToTags: migrating ====================
# -- add_column(:tags, :taggings_count, :integer, {:default=>0})
#    -> 0.0091s
# == 20161227054641 AddTaggingsCounterCacheToTags: migrated (0.0202s) ===========
#
# == 20161227054642 AddMissingTaggableIndex: migrating ==========================
# -- add_index(:taggings, [:taggable_id, :taggable_type, :context])
#    -> 0.0038s
# == 20161227054642 AddMissingTaggableIndex: migrated (0.0044s) =================
#
# == 20161227054643 ChangeCollationForTagNames: migrating =======================
# == 20161227054643 ChangeCollationForTagNames: migrated (0.0001s) ==============
#
# == 20161227054644 AddMissingIndexes: migrating ================================
# -- add_index(:taggings, :tag_id)
#    -> 0.0053s
# -- add_index(:taggings, :taggable_id)
#    -> 0.0029s
# -- add_index(:taggings, :taggable_type)
#    -> 0.0023s
# -- add_index(:taggings, :tagger_id)
#    -> 0.0029s
# -- add_index(:taggings, :context)
#    -> 0.0029s
# -- add_index(:taggings, [:tagger_id, :tagger_type])
#    -> 0.0027s
# -- add_index(:taggings, [:taggable_id, :taggable_type, :tagger_id, :context], {:name=>"taggings_idy"})
#    -> 0.0040s
# == 20161227054644 AddMissingIndexes: migrated (0.0236s) =======================
#
# == 20161230091405 RenameUserIdToOpenerIdInDiscussions: migrating ==============
# == 20161230091405 RenameUserIdToOpenerIdInDiscussions: migrated (0.0000s) =====
#
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
# UP UP UP UP UP UP UP UP UP UP UP UP UP UP UP UP
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
#
# # # # # # # # # # # # # # # # # # # # # # # # #
#
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
# DOWN DOWN DOWN DOWN DOWN DOWN DOWN DOWN DOWN DOWN
# RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN RUN
#
# ➜  camp_one git:(g4_tags) bundle exec rake db:migrate:down VERSION=20161227054644
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054644 AddMissingIndexes: reverting ================================
# -- index_name(:taggings, {:name=>"taggings_idy"})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "taggings_idy", true)
#    -> 0.0027s
# -- remove_index(:taggings, {:name=>"taggings_idy"})
#    -> 0.0017s
# -- index_name(:taggings, {:column=>[:tagger_id, :tagger_type]})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_tagger_id_and_tagger_type", true)
#    -> 0.0025s
# -- remove_index(:taggings, {:column=>[:tagger_id, :tagger_type], :name=>"index_taggings_on_tagger_id_and_tagger_type"})
#    -> 0.0145s
# -- index_name(:taggings, {:column=>:context})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_context", true)
#    -> 0.0021s
# -- remove_index(:taggings, {:column=>:context, :name=>"index_taggings_on_context"})
#    -> 0.0100s
# -- index_name(:taggings, {:column=>:tagger_id})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_tagger_id", true)
#    -> 0.0010s
# -- remove_index(:taggings, {:column=>:tagger_id, :name=>"index_taggings_on_tagger_id"})
#    -> 0.0116s
# -- index_name(:taggings, {:column=>:taggable_type})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_taggable_type", true)
#    -> 0.0019s
# -- remove_index(:taggings, {:column=>:taggable_type, :name=>"index_taggings_on_taggable_type"})
#    -> 0.0107s
# -- index_name(:taggings, {:column=>:taggable_id})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_taggable_id", true)
#    -> 0.0025s
# -- remove_index(:taggings, {:column=>:taggable_id, :name=>"index_taggings_on_taggable_id"})
#    -> 0.0056s
# -- index_name(:taggings, {:column=>:tag_id})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_tag_id", true)
#    -> 0.0009s
# -- remove_index(:taggings, {:column=>:tag_id, :name=>"index_taggings_on_tag_id"})
#    -> 0.0048s
# == 20161227054644 AddMissingIndexes: reverted (0.0756s) =======================
#
# ➜  camp_one git:(g4_tags) ✗ bundle exec rake db:migrate:down VERSION=20161227054643
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054643 ChangeCollationForTagNames: reverting =======================
# == 20161227054643 ChangeCollationForTagNames: reverted (0.0000s) ==============
#
# ➜  camp_one git:(g4_tags) ✗ bundle exec rake db:migrate:down VERSION=20161227054642
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054642 AddMissingTaggableIndex: reverting ==========================
# -- index_name(:taggings, {:column=>[:taggable_id, :taggable_type, :context]})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "index_taggings_on_taggable_id_and_taggable_type_and_context", true)
#    -> 0.0037s
# -- remove_index(:taggings, {:column=>[:taggable_id, :taggable_type, :context], :name=>"index_taggings_on_taggable_id_and_taggable_type_and_context"})
#    -> 0.0102s
# == 20161227054642 AddMissingTaggableIndex: reverted (0.0142s) =================
#
# ➜  camp_one git:(g4_tags) ✗ bundle exec rake db:migrate:down VERSION=20161227054641
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054641 AddTaggingsCounterCacheToTags: reverting ====================
# -- remove_column(:tags, :taggings_count)
#    -> 0.0023s
# == 20161227054641 AddTaggingsCounterCacheToTags: reverted (0.0023s) ===========
#
# ➜  camp_one git:(g4_tags) ✗ bundle exec rake db:migrate:down VERSION=20161227054640
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054640 AddMissingUniqueIndices: reverting ==========================
# -- index_name(:tags, {:column=>:name})
#    -> 0.0000s
# -- index_name_exists?(:tags, "index_tags_on_name", true)
#    -> 0.0031s
# -- remove_index(:tags, {:column=>:name, :name=>"index_tags_on_name"})
#    -> 0.0074s
# -- index_name(:taggings, {:name=>"taggings_idx"})
#    -> 0.0000s
# -- index_name_exists?(:taggings, "taggings_idx", true)
#    -> 0.0012s
# -- remove_index(:taggings, {:name=>"taggings_idx"})
#    -> 0.0018s
# -- index_name(:taggings, {:column=>["tag_id"]})
#    -> 0.0000s
# -- index_exists?(:taggings, :tag_id, {:name=>"index_taggings_on_tag_id"})
#    -> 0.0016s
# -- add_index(:taggings, :tag_id)
#    -> 0.0048s
# -- add_index(:taggings, [:taggable_id, :taggable_type, :context])
#    -> 0.0062s
# == 20161227054640 AddMissingUniqueIndices: reverted (0.0281s) =================
#
# ➜  camp_one git:(g4_tags) ✗ bundle exec rake db:migrate:down VERSION=20161227054639
# /work/teknuk/camp_one/app/controllers/application_controller.rb:36: warning: string literal in condition
# == 20161227054639 ActsAsTaggableOnMigration: reverting ========================
# -- drop_table(:taggings)
#    -> 0.0049s
# -- drop_table(:tags)
#    -> 0.0022s
# == 20161227054639 ActsAsTaggableOnMigration: reverted (0.0072s) ===============
#
#



