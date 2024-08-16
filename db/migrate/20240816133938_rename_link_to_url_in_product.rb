class RenameLinkToUrlInProduct < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :link, :url
  end
end
