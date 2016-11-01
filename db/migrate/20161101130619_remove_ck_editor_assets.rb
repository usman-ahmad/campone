class RemoveCkEditorAssets < ActiveRecord::Migration[5.0]
  def up
    drop_table :ckeditor_assets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
