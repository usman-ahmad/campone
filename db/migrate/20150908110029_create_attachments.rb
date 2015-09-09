class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.attachment :attachment
      t.text    :description
      t.integer :attachable_id
      t.string  :attachable_type
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
