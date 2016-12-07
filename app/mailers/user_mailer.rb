class UserMailer < ApplicationMailer

  def contribution_mail(contribution)
    @contribution = contribution
    subject = "You have been invited on #{@contribution.project.name} by #{@contribution.inviter.name}"
    mail(to: contribution.user.email, subject: subject)
  end
end
