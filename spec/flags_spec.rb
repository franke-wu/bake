#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'bake/util'
require 'cxxproject/utils/exit_helper'
require 'socket'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

  class DummyFlags
    attr_accessor :overwrite
    attr_accessor :add
    attr_accessor :remove
    
    def initialize(o,a,r)
      @overwrite = o
      @add = a
      @remove = r
    end
  end
  
describe "Flags" do

  it 'overwrite' do
    df = DummyFlags.new("-f -g","","")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df]).should == "-f -g"
  end

  it 'overwrite2' do
    df = DummyFlags.new("-f -g","-k","")
    df2 = DummyFlags.new("-h -i","","")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df, df2]).should == "-h -i"
  end


  it 'add' do
    df = DummyFlags.new("","-f -g","")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df]).should == "-x -y -z -f -g"
  end
  
  it 'add2' do
    df = DummyFlags.new("","-f -x -g","")
    df2 = DummyFlags.new("","-f -h","")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df, df2]).should == "-x -y -z -f -g -h"
  end

  it 'remove' do
    df = DummyFlags.new("","","-f -g -y -y -z")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df]).should == "-x"
  end

  it 'remove2' do
    df = DummyFlags.new("","","-x.x -z.* -y")
    orgStr = "-xxx -yyy -zzz"
    adjustFlags(orgStr,[df]).should == "-yyy"
  end

  it 'complex' do
    df = DummyFlags.new("","-a","-b")
    df1 = DummyFlags.new("-c -d","-h","-d")
    df2 = DummyFlags.new("","-e","-f")
    orgStr = "-x -y -z"
    adjustFlags(orgStr,[df,df1,df2]).should == "-c -h -e"
  end
 

end

end