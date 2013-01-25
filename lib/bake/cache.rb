require 'cxxproject/utils/exit_helper'
require 'cxxproject/utils/printer'
require 'bake/version'
require 'bake/options'

module Cxxproject

  class Cache
    attr_accessor :project2config
    attr_accessor :files # project_files
    attr_accessor :cache_file
    attr_accessor :version
    attr_accessor :workspace_roots
    attr_accessor :include_filter
    attr_accessor :exclude_filter
    attr_accessor :defaultToolchain
    attr_accessor :defaultToolchainTime
  end
  
  class CacheAccess
      attr_reader :defaultToolchain
      attr_reader :defaultToolchainTime
      attr_reader :cacheFilename
  
      def initialize(pm_filename, config_name, options)
        @cacheFilename = File.dirname(pm_filename)+"/.bake/"+File.basename(pm_filename)+"."+sanitize_filename(config_name)+".cache"
        FileUtils.mkdir_p(File.dirname(@cacheFilename))
        @options = options
        @defaultToolchain = nil
        @defaultToolchainTime = nil
      end
      
      def load_cache
        cache = nil
        begin
          allFiles = Dir.glob(File.dirname(@cacheFilename)+"/*.cache")
          if allFiles.include?(@cacheFilename)
            cacheTime = File.mtime(@cacheFilename)
            contents = File.open(@cacheFilename, "rb") {|io| io.read }
            cache = Marshal.load(contents)
            
            if cache.version != Version.bake
              Printer.printInfo("Info: cache version ("+cache.version+") does not match to bake version ("+Version.bake+"), reloading meta information")
              cache = nil
              @options.set_nocache # complete re-read 
            else
              @defaultToolchain = cache.defaultToolchain
              @defaultToolchainTime = cache.defaultToolchainTime
            end
              
            if cache != nil
              if cache.cache_file != @cacheFilename
                Printer.printInfo "Info: cache filename changed, reloading meta information"
                cache = nil
                @options.set_nocache # abs dir may wrong 
              end
            end
            
            if cache != nil
              cache.files.each do |c|
                if (not File.exists?(c))
                  Printer.printInfo "Info: meta file(s) renamed or deleted, reloading meta information"
                  cache = nil
                  @options.set_nocache # abs dir may wrong 
                  break
                end
              end
            end
            
            if cache != nil
              cache.project2config.each do |pname,config|
                if not File.exists?(config.file_name)
                  Printer.printInfo "Info: meta file(s) renamed or deleted, reloading meta information"
                  cache = nil
                  @options.set_nocache # abs dir may wrong 
                end
              end  
            end
              
            if cache != nil
              cache.files.each do |c|
                if File.mtime(c) > cacheTime
                  Printer.printInfo "Info: cache is out-of-date, reloading meta information"
                  cache = nil
                  break
                end
              end
            end

            if cache != nil
              if cache.workspace_roots.length == @options.roots.length
                cache.workspace_roots.each do |r|
                  if not @options.roots.include?r
                    break
                  end
                end  
              else
                cache = nil
              end
              Printer.printInfo "Info: specified roots differ from cached roots, reloading meta information" if cache.nil?
            end
            
            if cache != nil
              if (not @options.include_filter.eql?(cache.include_filter)) or (not @options.exclude_filter.eql?(cache.exclude_filter))
                cache = nil
                Printer.printInfo "Info: specified filters differ from cached filters, reloading meta information"
              end
            end 
            
          else
            Printer.printInfo("Info: cache not found, reloading meta information")
          end
          
        rescue ExitHelperException
          raise
        rescue
          Printer.printWarning "Warning: cache file corrupt, reloading meta information"
          cache = nil
        end      
        
        if cache != nil
          Printer.printInfo "Info: cache is up-to-date, loading cached meta information" if @options.verbose
          return cache.project2config
        end
        return nil
        
      end
      
      def write_cache(project_files, project2config, defaultToolchain, defaultToolchainTime)
        cache = Cache.new
        cache.project2config = project2config
        cache.files = project_files
        cache.cache_file = @cacheFilename
        cache.version = Version.bake
        cache.include_filter = @options.include_filter
        cache.exclude_filter = @options.exclude_filter
        cache.workspace_roots = @options.roots
        cache.defaultToolchain = defaultToolchain
        cache.defaultToolchainTime = defaultToolchainTime
        bbdump = Marshal.dump(cache)
        begin
          File.delete(@cacheFilename)
        rescue
        end
        File.open(@cacheFilename, 'wb') {|file| file.write(bbdump) }
      end
      
  end
  
 
end
  