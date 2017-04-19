module NotificationSettingsHelper
  def select_options_for_story_state
    [
        ['No state changes', 'no'],
        ['State changes relevant to me', 'relevant'],
        ['All state changes, on stories I follow', 'on_followed'],
        ['All state changes, on all stories in a project', 'all']
    ]
  end

  def select_options_for_comments
    [
        ['No Comments', 'no'],
        ['Mentions only', 'mentions'],
        ['All comments, on stories/epics I follow', 'on_followed'],
        ['All comments, on all stories/discussion in a project', 'all']
    ]
  end

  def select_options_for_commits
    [
        ['No commits', 'no'],
        ['Commits on stories I follow', 'on_followed'],
        ['Commits on all stories in a project', 'all']
    ]
  end

end
