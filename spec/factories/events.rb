# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  due_at      :date
#  project_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  names = ['Conference on ROR','How to Deploy','Sports','Project success party']
  description = ['Conference will be help at bukhari auditorium','Deployment will be on unicorn and nginx','Only Football allowed','All members of company are invited','']


  factory :event do
    sequence(:title) { |n| names[(n % names.size)]}
    sequence(:description) { |n| description[(n % description.size)]}
    project
    due_at Date.today
  end

end
