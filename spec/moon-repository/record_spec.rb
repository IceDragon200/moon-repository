require 'spec_helper'
require 'moon-repository/record'

describe Moon::Repo::Record do
  it 'test' do
    person = Fixtures::Person.new
    expect(person.id).to be_nil
    person.name = 'ThatGuy'
    person.save
    expect(person.id).not_to be_nil
    expect(Fixtures::People.exists?(person.id)).to eq(true)
    person.destroy
    expect(Fixtures::People.exists?(person.id)).to eq(false)
  end
end
