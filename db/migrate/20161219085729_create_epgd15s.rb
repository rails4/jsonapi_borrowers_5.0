class CreateEpgd15s < ActiveRecord::Migration[5.0]
  def change
    create_table :epgd15s do |t|
      t.string :station
      t.datetime :time
      t.float :temp
      t.float :dewp
      t.float :humid
      t.float :wind_dir
      t.float :wind_speed
      t.float :wind_gust
      t.float :precip
      t.float :pressure
      t.float :visib
      t.integer :year
      t.integer :month
      t.integer :day
      t.integer :hour
      t.integer :minute
      t.datetime :time_hour
    end
    add_index :epgd15s, :time
    add_index :epgd15s, :time_hour
  end
end
