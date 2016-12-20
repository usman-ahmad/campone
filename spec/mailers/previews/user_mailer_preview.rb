# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # To preview visit
  # http://localhost:3000/rails/mailers/user_mailer/contribution_mail
  def contribution_mail
    project = Project.new(title: '<Project Title>')
    user = User.new(email: 'invitee@example.com')
    inviter = User.new(name: '<Inviter Name>')
    contribution = Contribution.new(project: project, user: user, inviter: inviter, token: '<your-invitation-token>')
    UserMailer.contribution_mail(contribution)
  end
end
