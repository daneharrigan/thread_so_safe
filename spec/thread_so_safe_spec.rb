require "spec_helper"

describe ThreadSoSafe do
  before(:all) do
    @app_name = 'My.Application'
    @default_directory = '/tmp/thread_so_safe'
  end

  it "should be safe without passing the application name" do
    ThreadSoSafe.register_token(@app_name)
    ThreadSoSafe.in_sync?.should == true
  end

  it "should be safe with the application name passed" do
    ThreadSoSafe.register_token(@app_name)
    ThreadSoSafe.in_sync?(@app_name).should == true    
  end

  it "should encode the application name with md5" do
    ThreadSoSafe.send(:file_name,@app_name).should == Digest::MD5.hexdigest(@app_name)  
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
    file_name = ThreadSoSafe.send(:file_name, @app_name)
    ThreadSoSafe.send(:full_path, file_name).should == "#{@default_directory}/#{file_name}"
  end

  context "when another thread updates the thread-safe token" do
    before(:each) do
      ThreadSoSafe.register_token(@app_name)

      file_name = ThreadSoSafe.send(:file_name, @app_name)
      full_path = ThreadSoSafe.send(:full_path, file_name)

      File.stub!(:mtime).and_return(Time.now+100)
    end

    it "should not be safe without passing the application name" do
      ThreadSoSafe.in_sync?.should == false
    end

    it "should be safe with the application name passed" do
      ThreadSoSafe.in_sync?(@app_name).should == false
    end
  end

  context "when updating the thread-safe token" do
    before(:each) do
      ThreadSoSafe.register_token(@app_name)
      file_name = ThreadSoSafe.send(:file_name, @app_name)
      @full_path = ThreadSoSafe.send(:full_path, file_name)

      @mtime = File.mtime @full_path
      File.stub!(:mtime).and_return(Time.now+100)
    end

    it "should update the mtime on the /tmp file with the application name passed" do
      ThreadSoSafe.update!(@app_name)
      File.mtime(@full_path).should_not == @mtime
    end

    it "should update the mtime on the /tmp file without the application name passed" do
      ThreadSoSafe.update!
      File.mtime(@full_path).should_not == @mtime
    end
  end

  context "when resetting the thread-safe token" do
    before(:each) do
      ThreadSoSafe.register_token(@app_name)
      file_name = ThreadSoSafe.send(:file_name, @app_name)
      @full_path = ThreadSoSafe.send(:full_path, file_name)
    end

    it "should not be in sync" do
      ThreadSoSafe.reset!
      ThreadSoSafe.in_sync?.should == false
    end

    it "should update the timestamp on the /tmp file" do
      original_mtime = File.mtime(@full_path)
      sleep(1)
      ThreadSoSafe.reset!
      File.mtime(@full_path).should_not == original_mtime
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