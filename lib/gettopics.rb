#!/usr/bin/env ruby -w

require 'open-uri'
require 'rubygems'
require 'nokogiri'
list=[]
keep_list = %w{ technology healthcare-network tv-and-radio politics government-computing-network science education business  theguardian social-enterprise-network law commentisfree world environment news search theobserver society global-development money uk media }

doc = Nokogiri::XML(open("http://content.guardianapis.com/sections?format=xml&api-key=6q5un5uxfc2zqwqn9d28r7jj"))
(doc/'section').each do |section|
id = section['id'].to_s
list << id
puts id
end
puts list.inspect
list.reject! do |section|
  keep_list.include?(section)
end
puts 
puts list.inspect
puts
list.map! do |section|
  '-'+section
end
puts list.inspect
puts 
puts list.join(',')
  
