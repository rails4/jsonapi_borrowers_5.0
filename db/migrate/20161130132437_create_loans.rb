class CreateLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :loans do |t|
      t.text :notes
      t.boolean :returned
      t.references :friend, foreign_key: true
      t.references :article, foreign_key: true

      t.timestamps
    end
  end
end
