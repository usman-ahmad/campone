module ContributionsHelper
  def joined_status(contribution)
    contribution.user.invitation_accepted? ? 'Joined' : 'Awaiting'
  end
end
