#!/usr/bin/env ruby
# Author: Shawn Smith
# Purpose: Find all duplicate files within a directory.

require 'digest/sha1' # Needed for sha1
require 'optparse' # Needed for OptionParser

options = {}
find_paths = []

OptionParser.new do |opts|
	opts.on('-p', '--path PATH', 'Path to the directory to find duplicates in. (You may use this option more than once.)') do |path|
		if (find_paths.index(path) == nil)
			find_paths.push(path)
		elsif
			puts "Not adding duplicate path: #{path}"
		end
	end

	opts.on('-o', '--output-verbose [1|2|3]', 'Level of information to show. (3+ is for debuging)') do |verbose|
		options[:verbose] = verbose
	end

	opts.on('-d', '--delete', 'Delete the duplicates.') do
		options[:delete] = true
	end

	opts.on_tail('-h', '--help', 'Display help.') do
		puts opts
		exit
	end
end.parse!

puts "Settings:"
puts "- Verbose level: #{options[:verbose]}" if (options[:verbose])
puts "- Auto Delete: #{options[:delete]}" if (options[:delete])
puts "- Paths:"
find_paths.each do |x|
	puts "- - #{x}"
end
puts "--------------------------------------------------"

Files = {} # All files
Duplicates = {} # Only duplicates

find_paths.each do |z|
	Dir.chdir(z)
	puts "Changed to directory: #{z}" if (options[:verbose].to_i >= 1)

	Dir["*"].each do |x|
		if (File.file?(x))
			if (Files.has_value?(Digest::SHA1.file(x)))
				puts "Duplicate file found: #{Files.key(Digest::SHA1.file(x))} and #{Dir.pwd}/#{x}" if (options[:verbose].to_i >= 3)
				Duplicates["#{Dir.pwd}/#{x}"] = Files.key(Digest::SHA1.file(x))
			end

			Files["#{Dir.pwd}/#{x}"] = Digest::SHA1.file(x)

			puts "#{Dir.pwd}/#{x} - #{Digest::SHA1.file(x)}" if (options[:verbose].to_i >= 2)
		end
	end
end

Duplicates.each do |x, y|
	if (options[:delete])
		puts "Deleting file: #{x}, was duped with #{y}" if (options[:verbose].to_i >= 1)
		File.delete(x)
	else
		puts "DUPE: #{x} WITH: #{y}"
	end
end
