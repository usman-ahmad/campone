require 'rails_helper'

RSpec.describe VCSParser, type: :model do
  let(:user)    { create(:user) }
  let(:project) { create(:project, title: 'T i c k e t', owner: user) }
  let!(:task_1) { create(:task, project: project, requester: user, state: 'unstarted') }
  let!(:task_2) { create(:task, project: project, requester: user, state: 'unstarted') }

  it 'verifies default values' do
    expect(task_1.ticket_id).to eq 'ticket-1'
    expect(task_1.state).to eq 'unstarted'

    expect(task_2.ticket_id).to eq 'ticket-2'
    expect(task_2.state).to eq 'unstarted'
  end

  describe 'Available actions to complete a task' do
    actions = %w[fix fixes fixed complete completes completed close closes closed resolve resolves resolved]
    actions.each do |action|
      it "#{action.ljust(10)} ex: #{(action + ' ticket-1').ljust(20)} (marks ticket_1 as completed)" do
        expect { VCSParser::CommitParser.perform_actions!("#{action} #ticket-1") }.
            to change{ task_1.reload.state }.from('unstarted').to('finished')
      end
    end
  end

  describe 'Available actions to start state' do
    actions = %w[start starts started]
    actions.each do |action|
      it "#{action.ljust(10)} ex: #{(action + ' ticket-1').ljust(20)} (marks ticket_1 as started)" do
        expect { VCSParser::CommitParser.perform_actions!("#{action} #ticket-1") }.
            to change{ task_1.reload.state }.from('unstarted').to('started')
      end
    end
    
    it 'will not change start status if status is other than unstarted' do
      task_1.update_attributes(state: 'finished')
      expect { VCSParser::CommitParser.perform_actions!("start #ticket-1") }.
          to_not change{ task_1.reload.state }
    end
  end

  context "Two ticket_ids are referenced in single commit:" do

    commits = [
        { message: 'fix #ticket-1,#ticket-2',     des: 'separated by comma without any space between' },
        { message: 'fix #ticket-1 ,#ticket-2',    des: 'separated by comma and space on left' },
        { message: 'fix #ticket-1 , #ticket-2',   des: 'separated by comma and space on both side' },
        { message: 'fix #ticket-1 : #ticket-2',   des: 'separated by colon' },
        { message: 'fix #ticket-1; #ticket-2',    des: 'separated by semicolon' },
        { message: 'fix #ticket-1 & #ticket-2',   des: 'separated by & sign' },
        { message: 'fix #ticket-1 && #ticket-2',  des: 'separated by && sign' }
    ]

    commits.each do |commit|
      it "marks both tasks as completed ex: #{commit[:message].ljust(30)} (#{commit[:des]})" do
        expect { VCSParser::CommitParser.perform_actions!(commit[:message]) }.to change{ [task_1.reload.state, task_2.reload.state ] }.
                   from(['unstarted', 'unstarted']).to(['finished', 'finished'])
      end
    end
  end

  describe 'multiple actions a in single commit' do
    it "will mark ticket_1 as completed and ticket_2 as In state. ex: fixed #ticket-1 and started #ticket-2" do
      expect { VCSParser::CommitParser.perform_actions!('fixed #ticket-1 and started #ticket-2') }.
          to change{ [task_1.reload.state, task_2.reload.state ] }.
                 from(['unstarted', 'unstarted']).to(['finished', 'started'])
    end
  end

end
