class CreateOdds < ActiveRecord::Migration[7.0]
  def change
    create_table :odds do |t|
      t.string :race_id
      t.string :horse
      t.float :value

      t.timestamps
    end

    add_foreign_key :odds, :races
    add_index  :odds, :race_id
  end
end
