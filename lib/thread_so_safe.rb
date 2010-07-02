require 'digest/md5'
require 'fileutils'

class ThreadSoSafe
  @@threads = {}
  @@current_thread = nil

  class << self
    # Register thread/token
    def register_token(name)
      @@current_thread = name
      token = file_name(name)
      @@threads[token] = set_timestamp(token)
      return
    end

    # Have I been changed?
    def in_sync?(name=@@current_thread)
      @@current_thread = name
      token = file_name(name)

      @@threads[token] == File.read(full_path(token))
    end

    # Update myself and token and notify other threads
    def update!(name=@@current_thread)
      token = file_name(name)
      @@threads[token] = set_timestamp(token)
      return
    end

    # Update token only and notify other threads
    def reset!(name=@@current_thread)
      set_timestamp file_name(name)
      return
    end

    private
    #:nordoc:
    def file_name(name)
      Digest::MD5.hexdigest(name)
    end

    #:nordoc:
    def full_path(name)
      "#{directory}/#{name}"
    end

    #:nordoc:
    def directory
      use_default_directory? ? default_directory : gem_directory
    end

    #:nordoc:
    def use_default_directory?
      FileUtils.mkdir(default_directory) unless File.exists?(default_directory)
      File.writable?(default_directory)
    end

    #:nordoc:
    def default_directory
      '/tmp/thread_so_safe'
    end

    #:nordoc:
    def gem_directory
      File.expand_path(File.dirname(__FILE__)+'/../tmp')
    end

    #:nordoc:
    def set_timestamp(token)
      timestamp = Time.now.to_f.to_s
      File.open(full_path(token), 'w+') { |f| f.write timestamp }
      timestamp
    end
  end
end