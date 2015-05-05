require 'spec_helper'
require 'moon-repository/storage/memory'
require 'moon-repository/repository'

describe Moon::Repository do
  subject(:mem_repo) { Moon::Repository.new(Moon::Storage::Memory.new) }

  context '#all' do
    it 'returns all entries in the repository' do
      repo = mem_repo
      repo.clear
      repo.touch('1', name: 'First')
      repo.touch('2', name: 'Second')
      expect(repo.all).to eq({'1' => {name:'First'}, '2' => {name:'Second'}})
    end
  end
end
