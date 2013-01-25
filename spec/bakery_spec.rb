#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

ExitHelper.enable_exit_test

describe "bake" do

  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    SpecHelper.clean_testdata_build("root1","main","test")
    SpecHelper.clean_testdata_build("root1","lib1","test_main")
    SpecHelper.clean_testdata_build("root2","lib2","test_main")

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    ExitHelper.reset_exit_code
  end

  it 'collection double' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b double`
    str.include?("found more than once").should == true
  end  

  it 'collection empty' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gugu`
    str.include?("0 of 0 builds ok").should == true
  end  

  it 'collection onlyExclude' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gigi`
    str.include?("0 of 0 builds ok").should == true
    
  end  

  it 'collection working' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -w spec/testdata/root1 -w spec/testdata/root2`
    str.include?("2 of 2 builds ok").should == true
  end  

  it 'collection parse params' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -w spec/testdata/root1 -w spec/testdata/root2 -v -a black --ignore_cache -r -c`
    str.include?(" -r").should == true
    str.include?(" -a black").should == true
    str.include?(" -v").should == true
    str.include?(" --ignore_cache").should == true
    str.include?(" -r").should == true
    str.include?(" -c").should == true
  end
  
  it 'collection wrong' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2 -r`
    str.include?("bakery aborted").should == true
    str.include?("must contain DefaultToolchain").should == true
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2`
    str.include?("1 of 1 builds failed").should == true
  end  

  it 'collection error' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2 -r`
    str.include?("bakery aborted").should == true
    str.include?("Error: system command failed").should == false
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2`
    str.include?("1 of 1 builds failed").should == true
  end  
 
end

end