class CreateQuestionComments < ActiveRecord::Migration
  def change
    create_table :question_comments do |t|
      t.text :body, null: false
      t.integer :question_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
