class UserMailer < ApplicationMailer

  # To preview this email in browser without sending visit below link
  # http://localhost:3000/rails/mailers/user_mailer/contribution_mail
  def contribution_mail(contribution)
    @contribution = contribution
    subject = "You have been invited on #{@contribution.project.title} by #{@contribution.inviter.name}"
    mail(to: contribution.user.email, subject: subject)
  end
end
