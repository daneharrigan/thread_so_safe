# Register thread/token
# Have I been changed?
# Update myself/token and notify other threads
# Update token only and notify other threads
#
# ThreadSoSafe.register_token('this_that')
# ThreadSoSafe.in_sync?
# ThreadSoSafe.reset!
# ThreadSoSafe.update!


require 'digest/md5'
require 'fileutils'

class ThreadSoSafe
  @@threads = {}
  @@current_thread = nil

  class << self
    def register_token(name)
      @@current_thread = name
      name = file_name(name)
      path = full_path(name)

      FileUtils.touch(path) unless File.exists? path
      @@threads[name] = File.mtime(path)
      return
    end

    def in_sync?(name=@@current_thread)
      @@current_thread = name
      name = file_name(name)

      @@threads[name] == File.mtime("#{full_path name}")
    end

    def update!(name=@@current_thread)
      encoded_name = file_name(name)
      file = full_path(name)

      reset!(name) if @@threads[encoded_name] == File.mtime(file)
      @@threads[encoded_name] = File.mtime(file)
      return
    end

    def reset!(name=@@current_thread)
      file = full_path file_name(name)
      FileUtils.touch(file)
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