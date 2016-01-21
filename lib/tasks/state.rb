module State
# These would be possible states
# ['Started', 'In progress', 'Completed', 'Rejected', 'Accepted', 'Deployed','Closed']
  Possible_states = Task::PROGRESSES

  STATE_MACHINE= {
  :started     => [Possible_states[1], Possible_states[6]], # Started,  Closed
  :in_progress => [Possible_states[2], Possible_states[6]], # Completed,Closed
  :completed   => [Possible_states[4], Possible_states[3] , # Rejected, Accepted
                   Possible_states[5], Possible_states[6]], # Deploy,   Closed
  :rejected    => [Possible_states[0], Possible_states[6]], # Started,  Closed
  :deployed    => [Possible_states[4], Possible_states[3]], # Acceptd,  Rejected
  :accepted    => [Possible_states[5]],                     # Deploy
  :closed      => [Possible_states[0]],                     # Started
  }

end