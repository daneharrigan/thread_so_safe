require 'digest/md5'
require 'fileutils'

class ThreadSoSafe
  @@threads = {}
  @@current_thread = nil

  class << self
    # Register thread/token
    def register_token(name)
      @@current_thread = name
      name = file_name(name)
      path = full_path(name)

      FileUtils.touch(path) unless File.exists? path
      @@threads[name] = File.mtime(path)
      return
    end

    # Have I been changed?
    def in_sync?(name=@@current_thread)
      @@current_thread = name
      name = file_name(name)

      @@threads[name] == File.mtime("#{full_path name}")
    end

    # Update myself and token and notify other threads
    def update!(name=@@current_thread)
      encoded_name = file_name(name)
      file = full_path(name)

      reset!(name) if @@threads[encoded_name] == File.mtime(file)
      @@threads[encoded_name] = File.mtime(file)
      return
    end

    # Update token only and notify other threads
    def reset!(name=@@current_thread)
      file = full_path file_name(name)
      FileUtils.touch(file)
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
  end
end