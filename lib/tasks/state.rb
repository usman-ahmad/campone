module State
# These would be possible states
  PROG = Task::PROGRESSES

  GET_NEXT = {
      :started     => [PROG[:IN_PROGRESS], PROG[:CLOSED]],
      :in_progress => [PROG[:COMPLETED],   PROG[:CLOSED]],
      :completed   => [PROG[:REJECTED],    PROG[:ACCEPTED],
                       PROG[:DEPLOYED],    PROG[:CLOSED]],
      :rejected    => [PROG[:STARTED],     PROG[:CLOSED]],
      :deployed    => [PROG[:ACCEPTED],    PROG[:REJECTED]],
      :accepted    => [PROG[:DEPLOYED]],
      :closed      => [PROG[:STARTED]],
      :no_progress => [PROG[:STARTED]],
  }

end