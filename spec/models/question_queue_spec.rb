require 'rails_helper'

describe QuestionQueue do
  describe '#callbacks' do
    describe 'set_sort_order' do
      it 'sets the sort_order one higher than the highest' do
        qq1 = FactoryGirl.create(:question_queue)
        qq2 = FactoryGirl.create(:question_queue)
        expect(qq2.sort_order).to eq 2

        qq1.update_attribute(:sort_order, 5)
        qq3 = FactoryGirl.create(:question_queue)
        expect(qq3.sort_order).to eq 6
      end
    end
  end

  describe '#update_in_queue' do
    let(:user) { FactoryGirl.create(:user) }
    let(:experience_engineer) { FactoryGirl.create(:admin) }
    let(:team) { FactoryGirl.create(:team) }

    let(:question) { FactoryGirl.create(:question, user: user) }
    let!(:question_queue) { FactoryGirl.create(:question_queue, question: question, team: team) }

    it 'updates the user assigned to the current_user' do
      question_queue.update_in_queue('in-progress', experience_engineer)
      expect(question_queue.reload.user).to eq experience_engineer
    end

    context 'status in-progress' do
      it 'updates the status to in-progress' do
        question_queue.update_in_queue('in-progress', experience_engineer)
        expect(question_queue.reload.status).to eq 'in-progress'
      end
    end

    context 'status no-show' do
      it 'increments the no_show_counter' do
        expect(question_queue.reload.no_show_counter).to eq 0
        question_queue.update_in_queue('no-show', experience_engineer)
        expect(question_queue.reload.no_show_counter).to eq 1
      end

      it 'increments the sort_order' do
        expect(question_queue.reload.sort_order).to eq 1
        question_queue.update_in_queue('no-show', experience_engineer)
        expect(question_queue.reload.sort_order).to eq 2
      end

      context 'no_show_counter == 2' do
        before do
          question_queue.update_attributes(no_show_counter: 2)
        end

        it 'updates the status to done' do
          question_queue.update_in_queue('no-show', experience_engineer)
          expect(question_queue.reload.status).to eq 'done'
        end
      end

      context 'no_show_counter < 2' do
        it 'increments the no_show_counter' do
          question_queue.update_in_queue('no-show', experience_engineer)
          expect(question_queue.reload.no_show_counter).to eq 1
        end
      end
    end

    context 'status done' do
      it 'updates the status to done' do
        question_queue.update_in_queue('done', experience_engineer)
        expect(question_queue.reload.status).to eq 'done'
      end
    end
  end
end
