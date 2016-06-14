class CreateEcgStreams < ActiveRecord::Migration[5.0]
  def change
    create_table :ecg_streams do |t|
      t.integer :signal, array: true, limit: 2, default: []
      t.datetime :start_time
      t.datetime :end_time
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end