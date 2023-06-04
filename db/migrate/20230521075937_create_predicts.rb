class CreatePredicts < ActiveRecord::Migration[7.0]
  def change
    create_table :predicts do |t|
      t.string :orepro_predict_id
      t.string :user_id
      t.string :race_id
      t.string :mark
      t.string :horse

      t.timestamps
    end

    add_foreign_key :predicts, :users
    add_index  :predicts, :user_id

    add_foreign_key :predicts, :races
    add_index  :predicts, :race_id
  end
end
