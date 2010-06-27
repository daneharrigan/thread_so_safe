require 'digest/md5'
require 'fileutils'

class ThreadSoSafe
  @@threads = {}
  @@current_thread = nil

  class << self
    def safeguard(name)
      @@current_thread = name
      name = file_name(name)
      path = full_path(name)

      FileUtils.touch(path) unless File.exists? path
      @@threads[name] = File.mtime(path)
      return
    end

    def safe?(name=@@current_thread)
      @@current_thread = name
      name = file_name(name)

      @@threads[name] == File.mtime("#{full_path name}")
    end

    def update!(name=@@current_thread)
      name = file_name(name)
      file = full_path(name)

      FileUtils.touch(file) if @@threads[name] == File.mtime(file)
      @@threads[name] = File.mtime(file)
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