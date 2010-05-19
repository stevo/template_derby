RAILS_ROOT = File.join(File.dirname(__FILE__), '..', '..', '..') unless defined?(RAILS_ROOT)

begin
  puts "\n\n=========================================================="
  puts "Attempting to copy template derby defaults files into your application..."

  require 'fileutils'

  FileUtils.cp_r 'defaults/.', RAILS_ROOT, :remove_destination => false    

  puts "Success!"
  puts "=========================================================="
rescue Exception => ex
  raise ex
  puts "FAILED TO COPY LBUILDER DEFAULT FILES INTO YOUR APPLICATION."
  puts "EXCEPTION: #{ex}"
end