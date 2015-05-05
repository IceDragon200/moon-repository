require 'spec_helper'
require 'moon-repository/record'

describe Moon::Record do
  context '.repository' do
    it 'returns the active repository for the Record class' do
      repo = Fixtures::Book.repository
      expect(repo).to be_instance_of(Moon::Repository)
    end
  end

  context '.create' do
    it 'creates a new record' do
      book = Fixtures::Book.create(name: 'Test Book')
      book.destroy
    end
  end
end
