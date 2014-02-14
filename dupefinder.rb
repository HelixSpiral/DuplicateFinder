#!/usr/bin/env ruby
# Author: Shawn Smith
# Purpose: Find all duplicate files within a directory.

require 'digest/sha1' # Needed for sha1
require 'optparse' # Needed for OptionParser

options = {}
find_paths = []
ignore_paths = []
hashes = Hash.new {|hash,key| hash[key] = [] }
total_duplicates = 0

OptionParser.new do |opts|
	opts.on('-i', '--ignore-path PATH', 'Ignore these paths.') do |ipath|
		next if ignore_paths.index(ipath)

		ignore_paths.push(ipath)
	end

	opts.on('-p', '--path PATH', 'Paths to the directories to find duplicates in.') do |path|
		next if find_paths.index(path) || ignore_paths.index(path)

		find_paths.push(path)
	end

	opts.on('-r', '--recursive', 'Search recursively.') do
		options[:recursive] = true
	end

	opts.on('-v', '--verbose [1|2|3]', 'Level of information to show. (3+ is for debuging)') do |verbose|
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

# I realize this might be a bit inefficient, doing all this looping here only to do it again
# later when we loop to find duplicates, but if we don't loop here we can't collect all the
# subdirectories to put into find_paths.
# Since we're only checking if every file is a directory or not, I don't think this is too awful.
if (options[:recursive] == true)
	# Loop for the paths
	find_paths.each do |x|
		Dir.chdir(x)
		puts "Checking path: #{x}" if (options[:verbose].to_i >= 3)

		# Loop for everything in the directory.
		Dir["*"].each do |z|
			next unless File.directory?(z)
			next if ignore_paths.index(File.expand_path(z))

			find_paths.push(File.expand_path(z))

			puts "Found path: #{File.expand_path(z)}" if (options[:verbose].to_i >= 3)
		end
	end
end

# Display settings to the user.
puts "Settings:"
puts "- Verbosity Level: #{options[:verbose]}" if (options[:verbose])
puts "- Auto Delete: #{options[:delete]}" if (options[:delete])
puts "- Recursive Search: #{options[:recursive]}" if (options[:recursive])
puts "- Ignoring Paths:"
ignore_paths.each do |x|
	puts "- - #{x}"
end
puts "- Paths:"
find_paths.each do |x|
	puts "- - #{x}"
end
puts "--------------------------------------------------"

find_paths.each do |z|
	Dir.chdir(z)
	puts "Changed to directory: #{z}" if (options[:verbose].to_i >= 1)

	Dir["*"].each do |x|
		next unless File.file?(x)

		hash = Digest::SHA1.file(x)
		hashes["#{hash}"] << File.expand_path(x)

		puts "#{Dir.pwd}/#{x} - #{Digest::SHA1.file(x)}" if (options[:verbose].to_i >= 2)
	end
end

hashes.each do |hash, paths|
	next if paths.size < 2

	puts "Duplicates[#{hash}]", *paths, "\n"
	total_duplicates += paths.size
end

puts "Total duplicated files: #{total_duplicates}"