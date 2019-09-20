#!/usr/bin/env ruby

require 'bundler'
Bundler.require

require_relative './mp'

Mp.start(ARGV)