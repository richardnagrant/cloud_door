require 'spec_helper'

def create_file_list
  file_list = CloudDoor::FileList.new('test_list', './data/')
  file_list
end

describe 'FileList' do
  describe 'load_list' do
    subject { file_list.load_list }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items = {'id' => 'folder.1234', 'type' => 'folder'}
      [{'id' => 'top', 'name' => 'top', 'items' => items}]
    end
    context 'list file not exists' do
      it { is_expected.to be_truthy }
      it do
        subject
        expect(file_list.list).to eq []
      end
    end
    context 'list file is array' do
      before(:each) do
        open(list_file, 'wb') { |file| file << Marshal.dump(list) }
      end
      it { is_expected.to be_truthy }
      it do
        subject
        expect(file_list.list).to eq list
      end
    end
    context 'list file is not array' do
      let(:list) { '' }
      before(:each) do
        open(list_file, 'wb') { |file| file << Marshal.dump(list) }
      end
      it { is_expected.to be_falsey }
      it do
        subject
        expect(file_list.list).to eq nil
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'add_list_top' do
    subject { file_list.add_list_top(items) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    before(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
    context 'success' do
      let(:items) { {'folder' => {'id' => 'folder.1234', 'type' => 'folder'}} }
      let(:added_list) do
        [{'id' => 'top', 'name' => 'top', 'items' => items}]
      end
      it { is_expected.to be_truthy }
      it do
        subject
        file_list.load_list
        expect(file_list.list).to eq added_list
      end
    end
    context 'fail' do
      context 'items is nil' do
        let(:items) { nil }
        it { is_expected.to be_falsey }
      end
      context 'items is not hash' do
        let(:items) { [] }
        it { is_expected.to be_falsey }
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'add_list' do
    subject { file_list.add_list(items, file_id, file_name) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      [{'id' => 'top', 'name' => 'top', 'items' => top_items}]
    end
    let(:file_id) { 'folder.1234' }
    let(:file_name) { 'folder1' }
    let(:items) { {'test2' => {'id' => 'file.5678', 'type' => 'file'}} }
    let(:top_items) { {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}} }
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'success' do
      let(:added_list) do
        [
          {'id' => 'top', 'name' => 'top', 'items' => top_items},
          {'id' => file_id, 'name' => file_name, 'items' => items}
        ]
      end
      it { is_expected.to be_truthy }
      it do
        subject
        file_list.load_list
        expect(file_list.list).to eq added_list
      end
    end
    context 'fail' do
      context 'file_id is nil' do
        let(:file_id) { nil }
        it { is_expected.to be_falsey }
      end
      context 'file_id is empty' do
        let(:file_id) { '' }
        it { is_expected.to be_falsey }
      end
      context 'file_name is nil' do
        let(:file_name) { nil }
        it { is_expected.to be_falsey }
      end
      context 'file_name is empty' do
        let(:file_name) { '' }
        it { is_expected.to be_falsey }
      end
      context 'items is nil' do
        let(:items) { nil }
        it { is_expected.to be_falsey }
      end
      context 'items is not hash' do
        let(:items) { [] }
        it { is_expected.to be_falsey }
      end
      context 'list file is not array' do
        let(:list) do
          {'id' => 'top', 'name' => 'top', 'items' => top_items}
        end
        it { is_expected.to be_falsey }
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'update_list' do
    subject { file_list.update_list(items) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
      items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
      [
        {'id' => 'top', 'name' => 'top', 'items' => items1},
        {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
        {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
      ]
    end
    let(:items) { {'file4' => {'id' => 'file.7890', 'type' => 'file'}} }
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'success' do
      let(:updated_list) do
        items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
        items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
        [
          {'id' => 'top', 'name' => 'top', 'items' => items1},
          {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
          {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items}
        ]
      end
      it { is_expected.to be_truthy }
      it do
        subject
        file_list.load_list
        expect(file_list.list).to eq updated_list
      end
    end
    context 'fail' do
      context 'items is nil' do
        let(:items) { nil }
        it { is_expected.to be_falsey }
      end
      context 'items is not hash' do
        let(:items) { [] }
        it { is_expected.to be_falsey }
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'remove_list' do
    subject { file_list.remove_list(back) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
      items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
      [
        {'id' => 'top', 'name' => 'top', 'items' => items1},
        {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
        {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
      ]
    end
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'success' do
      context 'remove last 1' do
        let(:back) { 2 }
        it { is_expected.to be_truthy }
        it do
          subject
          file_list.load_list
          expect(file_list.list).to eq list[0..1]
        end
      end
      context 'remove last 2' do
        let(:back) { 3 }
        it { is_expected.to be_truthy }
        it do
          subject
          file_list.load_list
          expect(file_list.list).to eq list[0..0]
        end
      end
    end
    context 'fail' do
      context 'remove all' do
        let(:back) { 4 }
        it { is_expected.to be_falsey }
      end
      context 'list file is not array' do
        let(:list) do
          items = {'test' => {'id' => 'file.1234', 'type' => 'file'}}
          {'id' => 'top', 'name' => 'top', 'items' => items}
        end
        let(:back) { 1 }
        it { is_expected.to be_falsey }
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'delete_list' do
    subject { file_list.delete_file }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      [{'id' => 'top', 'name' => 'top', 'items' => items}]
    end
    context 'file not exists' do
      it { is_expected.to be_truthy }
      it do
        subject
        expect(File.exist?(file_list.list_file)).to be_falsey
      end
    end
    context 'file exists' do
      before(:each) do
        open(list_file, 'wb') { |file| file << Marshal.dump(list) }
      end
      it { is_expected.to be_truthy }
      it do
        subject
        expect(File.exist?(file_list.list_file)).to be_falsey
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'pull_parent_id' do
    subject { file_list.pull_parent_id }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
      items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
      [
        {'id' => 'top', 'name' => 'top', 'items' => items1},
        {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
        {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
      ]
    end
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    it { is_expected.to eq 'folder.5678' }
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'pull_current_dir' do
    subject { file_list.pull_current_dir }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'top' do
      let(:list) do
        items = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
        [{'id' => 'top', 'name' => 'top', 'items' => items}]
      end
      it { is_expected.to eq '/top' }
    end
    context 'directory' do
      let(:list) do
        items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
        items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
        items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
        [
          {'id' => 'top', 'name' => 'top', 'items' => items1},
          {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
          {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
        ]
      end
      it { is_expected.to eq '/top/folder1/folder2' }
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'pull_file_properties' do
    subject { file_list.pull_file_properties(file_name) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:file_name) { 'file3' }
    let(:list) do
      items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
      items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
      [
        {'id' => 'top', 'name' => 'top', 'items' => items1},
        {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
        {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
      ]
    end
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'target found' do
      it { is_expected.to eq({'id' => 'file.3456', 'type' => 'file'}) }
    end
    context 'target not found' do
      let(:file_name) { 'file4' }
      it { is_expected.to be_falsey }
    end
    context 'list is empty' do
      let(:list) { [] }
      it { is_expected.to be_falsey }
    end
    context 'items is empty' do
      let(:list) { [{'id' => 'top', 'name' => 'top', 'items' => {}}] }
      it { is_expected.to be_falsey }
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end

  describe 'convert_name_to_id' do
    subject { file_list.convert_name_to_id(mode, file_name) }
    let(:file_list) { create_file_list }
    let(:list_file) { './data/test_list' }
    let(:list) do
      items1 = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
      items2 = {'folder2' => {'id' => 'folder.5678', 'type' => 'folder'}}
      items3 = {'file3' => {'id' => 'file.3456', 'type' => 'file'}}
      [
        {'id' => 'top', 'name' => 'top', 'items' => items1},
        {'id' => 'folder.1234', 'name' => 'folder1', 'items' => items2},
        {'id' => 'folder.5678', 'name' => 'folder2', 'items' => items3}
      ]
    end
    before(:each) do
      open(list_file, 'wb') { |file| file << Marshal.dump(list) }
    end
    context 'mode == current' do
      let(:mode) { 'current' }
      let(:file_name) { nil }
      context 'top' do
        let(:list) do
          items = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
          [{'id' => 'top', 'name' => 'top', 'items' => items}]
        end
        it { is_expected.to be_nil }
      end
      context 'directory' do
        it { is_expected.to eq 'folder.5678' }
      end
    end
    context 'mode == parent' do
      let(:mode) { 'parent' }
      context 'top' do
        let(:file_name) { '../' }
        let(:list) do
          items = {'folder1' => {'id' => 'folder.1234', 'type' => 'folder'}}
          [{'id' => 'top', 'name' => 'top', 'items' => items}]
        end
        it { is_expected.to be_falsey }
      end
      context 'back to folder' do
        let(:file_name) { '../' }
        it { is_expected.to eq 'folder.1234' }
      end
      context 'back to top' do
        let(:file_name) { '../../' }
        it { is_expected.to be_nil }
      end
    end
    context 'mode == target' do
      let(:mode) { 'target' }
      let(:file_name) { 'file3' }
      context 'target found' do
        it { is_expected.to eq 'file.3456' }
      end
      context 'target not found' do
        let(:file_name) { 'file4' }
        it { is_expected.to be_falsey }
      end
      context 'list is empty' do
        let(:list) { [] }
        it { is_expected.to be_falsey }
      end
      context 'items is empty' do
        let(:list) { [{'id' => 'top', 'name' => 'top', 'items' => {}}] }
        it { is_expected.to be_falsey }
      end
    end
    after(:each) do
      File.delete(list_file) if File.exist?(list_file)
    end
  end
end
