class Ability
  include CanCan::Ability

  # Anything except deleting a project
  MANAGER = Contribution::ROLES[:manager]

  # Full edit/delete access without ability to invite people or add integrations
  MEMBER = Contribution::ROLES[:member]

  # Can only view tasks, comments, and other items created by other users.
  GUEST = Contribution::ROLES[:guest]

  def initialize(user)

    # Guest User
    user ||= User.new
    if (user.new_record?)
      can :manage, User
    end

    # Project Permissions
    can :manage, Project, owner: user
    # All roles can read project
    can :read, Project, :contributions => {:role => [MANAGER, MEMBER, GUEST], user_id: user.id}
    # manager can update project
    can :update, Project, :contributions => {:role => MANAGER, user_id: user.id}

    can :manage, Task
    can :manage, Discussion
    can :manage, Attachment

    can :create, Contribution do |contribution|
      contribution.project.contributions.where(role: MANAGER, user_id: user.id).present?
    end

    can :manage, Contribution, :project => {owner_id: user.id}

    # User can only manage his comments
    can :manage, Comment, user: user

    # can :read, Project, :category => { :visible => true }
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
