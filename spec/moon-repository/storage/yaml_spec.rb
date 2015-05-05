require 'spec_helper'
require 'yaml'
require 'moon-repository/storage/yaml'

describe Moon::Storage::YAMLStorage do
  context '#load' do
    it 'loads an existing store' do
      described_class.new(data_pathname('yaml_load_test.yml'))
    end
  end

  context '#save' do
    it 'saves a store' do
      storage = described_class.new(data_pathname('yaml_save_test.yml'))
      storage.update({'1' => { name: 'Data' }})
      storage.save
    end
  end
end
