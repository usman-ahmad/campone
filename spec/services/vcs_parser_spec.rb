require 'rails_helper'

RSpec.describe VCSParser, type: :model do
  let(:user)   { create(:user) }
  let(:project){ create(:project, name: 'T i c k e t', owner: user) }
  let(:task_1) { create(:task, project: project, creator: user) }
  let(:task_2) { create(:task, project: project, creator: user) }

  it 'marks a ticket as completed' do
    expect(task_1.ticket_id).to eq 'ticket-1'
    expect(task_1.progress).to eq 'No progress'

    expect { VCSParser::CommitParser.perform_actions!("This fixed #ticket-1") }.
        to change{ task_1.reload.progress }.from('No progress').to('Completed')
  end

  commits = [
      { message: 'fix #ticket-1,#ticket-2',     dis: 'separated by comma without andy space between' },
      { message: 'fix #ticket-1 ,#ticket-2',    dis: 'separated by comma and space on left' },
      { message: 'fix #ticket-1 , #ticket-2',   dis: 'separated by comma and space on both side' },
      { message: 'fix #ticket-1 : #ticket-2',   dis: 'separated by colon' },
      { message: 'fix #ticket-1; #ticket-2',    dis: 'separated by semicolon' },
      { message: 'fix #ticket-1 & #ticket-2',   dis: 'separated by & sign' },
      { message: 'fix #ticket-1 && #ticket-2',  dis: 'separated by && sign' }
  ]
  
  context "two ticket_ids referenced in single commit message, marks both as completed." do
    commits.each do |commit|
      it "commit message is: '#{commit[:message]}' (#{commit[:dis]})" do
        expect { VCSParser::CommitParser.perform_actions!(commit[:message]) }.to change{ [task_1.reload.progress, task_2.reload.progress ] }.
                   from(['No progress', 'No progress']).to(['Completed', 'Completed'])
      end
    end
  end

end
