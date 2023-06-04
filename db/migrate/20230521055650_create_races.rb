class CreateRaces < ActiveRecord::Migration[7.0]
  def change
    create_table :races, id: :string do |t|
      t.integer :number
      t.string :name
      t.string :place
      t.date :date

      t.timestamps
    end
  end
end
