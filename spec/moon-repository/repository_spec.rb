require 'spec_helper'
require 'moon-repository/repository'

describe Moon::Repo::Repository do
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
      expect(people.size).to eq(2)
      people.each do |person|
        expect(person).to be_kind_of(Fixtures::Person)
      end
    end
  end

  context '#find' do
    it 'should find a model by id' do
      Fixtures::People.clear_all # ensure we're working with a fresh set
      expected = Fixtures::People.create name: 'ThatGuy'
      actual = Fixtures::People.find expected.id
      expect(actual).to equal(expected)
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
      expect(actual).to equal(expected)
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
