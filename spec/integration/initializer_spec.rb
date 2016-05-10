require 'spec_helper'
require './lib/renuo/bin-check/initializer'

RSpec.describe RenuoBinCheck::Initializer do
  let(:bin_check) { RenuoBinCheck::Initializer.new }

  after(:each) { FileUtils.remove_dir('./tmp/bin-check/spec') }

  context 'passing script' do
    it 'runns the whole application as expected' do
      bin_check.check do |config|
        config.command './spec/spec-files/test_script_exit0'
        config.files %w(file1 file2)
      end
      expect do
        begin
          bin_check.run
        rescue SystemExit => se
          expect(se.status).to eq(0)
        end
      end.to output("I passed\nThis is the second line\n").to_stdout
    end
  end

  context 'failing script' do
    it 'runns the whole application as expected' do
      bin_check.check do |config|
        config.command './spec/spec-files/test_script_exit1'
        config.files %w(file1 file2)
      end
      expect do
        begin
          bin_check.run
        rescue SystemExit => se
          expect(se.status).to eq(1)
        end
      end.to output("I failed\nThis is the second line\n").to_stderr
    end
  end

  context 'cached script' do
    before(:each) do
      FileUtils.mkdir_p 'tmp/bin-check/spec/spec-files/test_script_exit0/f75c3cee2826ea881cb41b70b2d333b1'
      File.write 'tmp/bin-check/spec/spec-files/test_script_exit0/f75c3cee2826ea881cb41b70b2d333b1/output',
                 "I'm cached\npassed\n"
      File.write 'tmp/bin-check/spec/spec-files/test_script_exit0/f75c3cee2826ea881cb41b70b2d333b1/error_output',
                 "I'm cached\npassed\n"
      File.write 'tmp/bin-check/spec/spec-files/test_script_exit0/f75c3cee2826ea881cb41b70b2d333b1/exit_code', 0
    end

    it 'runns the whole application as expected' do
      bin_check.check do |config|
        config.command './spec/spec-files/test_script_exit0'
        config.files %w(./spec/spec-files/file1 ./spec/spec-files/file2)
      end
      expect do
        begin
          bin_check.run
        rescue SystemExit => se
          expect(se.status).to eq(0)
        end
      end.to output("I'm cached\npassed\n").to_stdout
    end
  end
end
