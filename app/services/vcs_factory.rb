class VCSFactory
  attr_accessor :payload

  def initialize(payload)
      @payload = payload
  end

  def get_vcs
    (@payload.integration.vcs_name + 'Parser').classify.constantize.new(@payload)
  end
end