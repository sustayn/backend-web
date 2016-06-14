class CreateStreamAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :stream_alerts do |t|
      t.integer :signal, array: true, limit: 2, default: []
      t.datetime :start_time
      t.datetime :end_time
      t.string :alert
      t.belongs_to :ecg_stream, foreign_key: true, index: true

      t.timestamps
    end
  end
end