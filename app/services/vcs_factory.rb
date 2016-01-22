class VCSFactory
  attr_accessor :payload

  def initialize(payload)
      @payload = payload
  end

  def get_vcs
    (@payload.integration.name + 'Parser').classify.constantize.new(@payload)
  end
end