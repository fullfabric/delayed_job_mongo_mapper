require 'spec_helper'

describe Delayed::Backend::MongoMapper::Job do
  it_should_behave_like 'a delayed_job backend'

  describe "reserve" do
    let(:worker) { Delayed::Worker.new }
    let(:failure) { Mongo::Error::OperationFailure.new("not primary") }

    before do
      allow_any_instance_of(Mongo::Collection).to receive(:find_one_and_update).and_raise(failure)
    end

    # An empty queue returns nil without raising; the worker's reserve_job logs real errors.
    it "raises the server's error" do
      expect { described_class.reserve(worker) }.to raise_error(failure)
    end
  end

  describe "before_fork" do
    after do
      ::MongoMapper.connection.close
    end

    it "should disconnect" do
      # On newer versions of the MongoDB driver, this test will be possible:
      # lambda do
      #   Delayed::Backend::MongoMapper::Job.before_fork
      # end.should change { !!MongoMapper.connection.closed? }.from(false).to(true)

      expect(MongoMapper.connection).to receive(:close)
    end
  end

  describe "after_fork" do
    before do
      ::MongoMapper.connection.close
    end

    it "should call reconnect" do
      # On newer versions of the MongoDB driver, this test will be possible:
      # lambda do
      #   Delayed::Backend::MongoMapper::Job.after_fork
      # end.should change { !!MongoMapper.connection.closed? }.from(true).to(false)

      expect(MongoMapper.connection).to receive(:reconnect)
      Delayed::Backend::MongoMapper::Job.after_fork
    end
  end
end
