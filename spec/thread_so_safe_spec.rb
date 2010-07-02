require "spec_helper"

describe ThreadSoSafe do
  before(:all) do
    @token = 'My.Application'
    @default_directory = '/tmp/thread_so_safe'

    ThreadSoSafe.register_token(@token)
  end
  
  after(:suite) do
    gem_directory = ThreadSoSafe.send(:gem_directory)
  
    FileUtils.rm_rf(@default_directory) if File.exists?(@default_directory)
    FileUtils.rm_rf("#{gem_directory}/*")
  end

  it "should be in-sync without passing the token" do
    ThreadSoSafe.in_sync?.should == true
  end

  it "should be in-sync with the token passed" do
    ThreadSoSafe.in_sync?(@token).should == true
  end

  it "should encode the token with md5" do
    ThreadSoSafe.send(:file_name,@token).should == Digest::MD5.hexdigest(@token)  
  end

  it "should return /tmp/thread_so_safe as the default directory" do
    ThreadSoSafe.send(:default_directory).should == @default_directory
  end

  it "should return <gem-path>/tmp as the default directory" do
    path_from_class = File.expand_path ThreadSoSafe.send(:gem_directory)
    path_from_test = File.expand_path(File.dirname(__FILE__) + '/../tmp')
    path_from_class.should == path_from_test
  end

  it "should return default directory" do
    ThreadSoSafe.send(:directory).should == @default_directory
  end

  it "should return the full path to the /tmp file" do
    file_name = ThreadSoSafe.send(:file_name, @token)
    ThreadSoSafe.send(:full_path, file_name).should == "#{@default_directory}/#{file_name}"
  end

  context "when another thread updates the thread-safe token" do
    before(:all) do
      file_name = ThreadSoSafe.send(:file_name, @token)
      full_path = ThreadSoSafe.send(:full_path, file_name)

      File.open(full_path, 'w') { |f| f.write(Time.now.to_f) }
    end

    it "should not be safe without passing the token" do
      ThreadSoSafe.in_sync?.should == false
    end

    it "should be safe with the token passed" do
      ThreadSoSafe.in_sync?(@token).should == false
    end
  end

  context "when updating the thread-safe token" do
    before(:all) do
      file_name = ThreadSoSafe.send(:file_name, @token)
      @full_path = ThreadSoSafe.send(:full_path, file_name)
      @file_content = File.read(@full_path)
    end

    it "should update the file content in on the /tmp file with the token passed" do
      ThreadSoSafe.update!(@token)
      File.read(@full_path).should_not == @file_content
    end

    it "should update the file content on the /tmp file without the token passed" do
      ThreadSoSafe.update!
      File.read(@full_path).should_not == @file_content
    end
  end

  context "when resetting the thread-safe token" do
    before(:all) do
      file_name = ThreadSoSafe.send(:file_name, @token)
      @full_path = ThreadSoSafe.send(:full_path, file_name)
    end

    it "should not be in sync without the token passed" do
      ThreadSoSafe.reset!
      ThreadSoSafe.in_sync?.should == false
    end

    it "should not be in sync with the token passed" do
      ThreadSoSafe.reset!(@token)
      ThreadSoSafe.in_sync?.should == false
    end

    it "should update the file content on the /tmp file without the token passed" do
      file_content = File.read(@full_path)
      ThreadSoSafe.reset!
      File.read(@full_path).should_not == file_content
    end

    it "should update the file content on the /tmp file with the token passed" do
      file_content = File.read(@full_path)
      ThreadSoSafe.reset!(@token)
      File.read(@full_path).should_not == file_content
    end
  end

  context "when the /tmp directory is not available or writable" do
    before(:each) do
      ThreadSoSafe.stub!(:use_default_directory?).and_return(false)
    end

    it "should return gem directory" do
      path_from_class = ThreadSoSafe.send(:directory)
      path_from_test = File.expand_path(File.dirname(__FILE__) + '/../tmp')
      path_from_class.should == path_from_test
    end    
  end
end