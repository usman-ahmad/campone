class UserMailer < ApplicationMailer

  # To preview this email in browser without sending visit below link
  # http://localhost:3000/rails/mailers/user_mailer/contribution_mail
  def contribution_mail(contribution)
    @contribution = contribution
    @inviter_name = contribution.inviter.name
    @project_title = contribution.project.title
    mail(to: contribution.user.email, subject:
        I18n.t('devise.mailer.invitation_instructions.subject_added',
               inviter_name: @inviter_name, project_title: @project_title))
  end
end
