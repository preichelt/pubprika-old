module ModelSpecHelpers
  def should_validate_presence(*fields)
    instance = described_class.new
    expect(instance).to_not be_valid
    fields.each do |field|
      expect(instance.errors[field]).not_to be_empty
      expect(instance.errors[field]).to be_any {|e| e.match /can't be blank/}
    end
  end

  def has_associations(*associations)
    instance = described_class.new
    associations.each do |a|
      expect do
        instance.send(a)
      end.to_not raise_error
    end
  end
end
