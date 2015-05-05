require 'spec_helper'
require 'moon-repository/record'

describe Moon::Record::InstanceMethods do
  context '#update' do
    it 'updates an existing record' do
      person = Fixtures::People.create(name: 'ThatGuy')
      expect(person.name).to eq('ThatGuy')
      expect(person.exists?).to eq(true)
      person.update(name: 'SomeGuy')
      expect(person.name).to eq('SomeGuy')
      person.destroy
    end
  end

  context '#save' do
    it 'saves a record' do
      person = Fixtures::Person.new
      person.name = 'ThatGuy'
      person.save

      person2 = Fixtures::People.find_by(name: 'ThatGuy')
      expect(person2.name).to eq(person.name)
    end
  end

  context '#destroy' do
    it 'destroys an existing record' do
      person = Fixtures::People.create(name: 'ThatGuy')
      person.destroy
      expect(person).to be_destroyed
      expect(person.exists?).to eq(false)
    end
  end
end
