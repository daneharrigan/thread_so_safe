require 'digest/md5'
require 'fileutils'

class ThreadSoSafe
  @@threads = {}
  @@current_token = nil

  class << self
    # register_token - This method creates and/or resumes existing ThreadSoSafe
    # sessions. register_token accepts one parameter as a string. Multiple tokens can
    # be registered ThreadSoSafe but only one at a time. The last registered_token is
    # stored in @@current_token. Storing the last token allows for later methods to
    # process without needing the token passed.
    #
    # ==== Example
    #   ThreadSoSafe.register_token('My.Application')
    #   ThreadSoSafe.register_token('My.Application Users')
    def register_token(name)
      @@current_token = name
      token = file_name(name)
      @@threads[token] = set_timestamp(token)
      return
    end

    # in_sync? - This method returns a boolean value indicating whether or not the
    # current thread is in sync with any other thread/application using the same
    # token. in_sync? accepts a token, but isn't necessary if there is only one
    # token registered in your application. If you have multiple tokens it's
    # necessary to pass the token when checking if your thread is in-sync.
    # 
    # ==== Example
    #   if ThreadSoSafe.in_sync?
    #     puts "Good thing I'm the only token registered!"
    #   end
    #
    #   # with multiple tokens
    #   if ThreadSoSafe.in_sync?('My.Application')
    #     puts "We're still synced"
    #   end
    #
    #   if ThreadSoSafe.in_sync?('My.Application Users')
    #     puts "Users are synced as well"
    #   end
    def in_sync?(name=@@current_token)
      token = file_name(name)

      @@threads[token] == File.read(full_path(token))
    end

    # Update myself and token and notify other threads
    def update!(name=@@current_token)
      token = file_name(name)
      file_content = File.read full_path(token)
      if @@threads[token] == file_content
        @@threads[token] = set_timestamp(token)
      else
        @@threads[token] = file_content
      end
      return
    end

    # Update token only and notify other threads
    def reset!(name=@@current_token)
      set_timestamp file_name(name)
      return
    end

    private
    def file_name(name)
      Digest::MD5.hexdigest(name)
    end

    def full_path(name)
      "#{directory}/#{name}"
    end

    def directory
      use_default_directory? ? default_directory : gem_directory
    end

    def use_default_directory?
      FileUtils.mkdir(default_directory) unless File.exists?(default_directory)
      File.writable?(default_directory)
    end

    def default_directory
      '/tmp/thread_so_safe'
    end

    def gem_directory
      File.expand_path(File.dirname(__FILE__)+'/../tmp')
    end

    def set_timestamp(token)
      timestamp = Time.now.to_f.to_s
      File.open(full_path(token), 'w+') { |f| f.write timestamp }
      timestamp
    end
  end
end