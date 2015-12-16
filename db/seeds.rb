# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# User email = teknuk-salman@ruby.com
# password = secretpassword
require 'factory_girl'

puts 'db/seeds started'


puts 'creating user'
user = FactoryGirl.create_list(:user,5)

puts 'creating Project'
project = FactoryGirl.create(:project, owner: user.first)

puts 'creating project_with_single_task'
single_task_project = FactoryGirl.create(:project_with_single_task, owner: user.first)

puts 'creating project_with_many_tasks'
many_tasks_project = FactoryGirl.create(:project_with_many_tasks, owner: user.first)

puts 'creating project_with_discussions'
project_with_discussions = FactoryGirl.create(:project_with_discussions, owner: user.first)

puts 'creating project_with_task_discussions'
project_with_task_discussions = FactoryGirl.create(:project_with_task_discussions, owner: user.first)

puts 'creating discussion'
discussion = FactoryGirl.create(:private_discussion, project: project, commenter: project.owner, user: project.owner)

projects =[project,single_task_project, many_tasks_project, project_with_discussions, project_with_task_discussions]

puts 'creating user_discussion and invitations'
user.each do |user|
  FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
end

FactoryGirl.create(:organizer_invitation, user: user[1], project: projects[0])
FactoryGirl.create(:team_player_invitation, user: user[1], project: projects[1])
FactoryGirl.create(:contributor_invitation, user: user[2], project: projects[2])
FactoryGirl.create(:organizer_invitation, user: user[4], project: projects[3])
FactoryGirl.create(:contributor_invitation, user: user[4], project: projects[4])

PublicActivity::Activity.all.each do |activity|
  activity.create_notification
end