class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.text :prompt
      t.boolean :chosen

      t.timestamps
    end
  end
end
