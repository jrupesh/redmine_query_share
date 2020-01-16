class CreateQueryUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :queries_users, :id => false do |t|
      t.column :query_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    add_index :queries_users, [:query_id, :user_id], :unique => true, :name => :queries_users_ids
  end
end
