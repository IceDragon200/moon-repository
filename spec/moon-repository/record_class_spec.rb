require 'spec_helper'
require 'moon-repository/repository'

describe Moon::Record::ClassMethods do
  context '#create' do
    it 'should create a new model' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      person = Fixtures::People.create
      expect(person.id).not_to be_nil
      expect(Fixtures::People.exists?(person.id)).to eq(true)
      person.destroy
      expect(Fixtures::People.exists?(person.id)).to eq(false)
    end
  end

  context '#all' do
    it 'should return a Collection of all the models' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      Fixtures::People.create name: 'ThatGuy'
      Fixtures::People.create name: 'SomeGuy'
      people = Fixtures::People.all
      expect(people.count).to eq(2)
      people.each do |person|
        expect(person).to be_kind_of(Fixtures::Person)
      end
      Fixtures::People.clear_all
      people = Fixtures::People.all
      expect(people.count).to eq(0)
    end
  end

  context '#update_all' do
    it 'updates all existing records' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      p1 = Fixtures::People.create(name: 'ThatGuy')
      p2 = Fixtures::People.create(name: 'SomeGuy')

      expect(p1.junk).to eq(0)
      expect(p2.junk).to eq(0)

      Fixtures::People.update_all(junk: 2)

      p1 = Fixtures::People.get(p1.id)
      p2 = Fixtures::People.get(p2.id)

      expect(p1.junk).to eq(2)
      expect(p2.junk).to eq(2)
    end
  end

  context '#destroy_all' do
    it 'destroys all records' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      Fixtures::People.create(name: 'ThatGuy')
      Fixtures::People.create(name: 'SomeGuy')
      Fixtures::People.destroy_all
      expect(Fixtures::People.count).to eq(0)
    end
  end

  context '#destroy_all' do
    it 'deletes all records' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      Fixtures::People.create(name: 'ThatGuy')
      Fixtures::People.create(name: 'SomeGuy')
      Fixtures::People.delete_all
      expect(Fixtures::People.count).to eq(0)
    end
  end

  context '#find' do
    it 'should find a model by id' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      expected = Fixtures::People.create name: 'ThatGuy'
      actual = Fixtures::People.find expected.id
      expect(actual.record_data).to eq(expected.record_data)
      expected.destroy
    end
  end

  context '#find_by' do
    it 'should find a model by given criteria' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      Fixtures::People.create name: 'Superman'
      expected = Fixtures::People.create name: 'Batman'
      Fixtures::People.create name: 'Wonderman' # cool song yo
      actual = Fixtures::People.find_by name: 'Batman'
      expect(actual.record_data).to eq(expected.record_data)
      expected.destroy
    end
  end

  context '#destroy_all' do
    it 'should destroy all models' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      Fixtures::People.create name: 'ThatGuy'
      Fixtures::People.create name: 'SomeGuy'
      expect(Fixtures::People.count).to eq(2)
      Fixtures::People.destroy_all
      expect(Fixtures::People.count).to eq(0)
    end
  end
end
