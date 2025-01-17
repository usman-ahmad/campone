# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# require 'factory_girl'

# puts 'db/seeds started'
#
# puts 'creating user'
# user = FactoryGirl.create_list(:user, 5)
#
# puts 'creating Project'
# project = FactoryGirl.create(:project, owner: user.first)
#
# puts 'creating project_with_single_story'
# single_story_project = FactoryGirl.create(:project_with_single_story, owner: user.first)
#
# puts 'creating project_with_many_stories'
# many_stories_project = FactoryGirl.create(:project_with_many_stories, owner: user.first)
#
# puts 'creating project_with_discussions'
# project_with_discussions = FactoryGirl.create(:project_with_discussions, owner: user.first)
#
# puts 'creating project_with_story_discussions'
# project_with_story_discussions = FactoryGirl.create(:project_with_story_discussions, owner: user.first)
#
# puts 'creating discussion'
# discussion = FactoryGirl.create(:private_discussion, project: project, commenter: project.owner, user: project.owner)
#
# projects =[project, single_story_project, many_stories_project, project_with_discussions, project_with_story_discussions]
#
# puts 'creating user_discussion and contributions'
# user.each do |user|
#   FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
# end
#
# FactoryGirl.create(:manager_contribution, user: user[1], project: projects[0])
# FactoryGirl.create(:member_contribution, user: user[1], project: projects[1])
# FactoryGirl.create(:guest_contribution, user: user[2], project: projects[2])
# FactoryGirl.create(:manager_contribution, user: user[4], project: projects[3])
# FactoryGirl.create(:guest_contribution, user: user[4], project: projects[4])
#
# PublicActivity::Activity.all.each do |activity|
#   activity.create_notification
# end
