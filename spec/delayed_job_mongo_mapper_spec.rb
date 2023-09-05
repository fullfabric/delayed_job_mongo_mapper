require 'spec_helper'

describe Delayed::Backend::MongoMapper::Job do
  it_should_behave_like 'a delayed_job backend'

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
