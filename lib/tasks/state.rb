module State
# These would be possible states
# ['No progress',Started', 'In progress', 'Completed', 'Rejected', 'Accepted', 'Deployed','Closed']
  Possible_states = Task::PROGRESSES

  STATE_MACHINE= {
  :started     => [Possible_states[2], Possible_states[7]], # In progress,  Closed
  :in_progress => [Possible_states[3], Possible_states[7]], # Completed,Closed
  :completed   => [Possible_states[4], Possible_states[5] , # Rejected, Accepted
                   Possible_states[6], Possible_states[7]], # Deploy,   Closed
  :rejected    => [Possible_states[1], Possible_states[7]], # Started,  Closed
  :deployed    => [Possible_states[5], Possible_states[4]], # Acceptd,  Rejected
  :accepted    => [Possible_states[6]],                     # Deploy
  :closed      => [Possible_states[1]],                     # Started
  :no_progress => [Possible_states[1]],                     # Started,
  }

end