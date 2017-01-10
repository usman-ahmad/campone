class TagListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || 'is not valid') unless value.to_s =~ /\A[\w\-\,\s]+\z/i
  end
end
