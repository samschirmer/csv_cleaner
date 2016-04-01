require 'csv'    

puts "\t"
print "What's the name of the CSV file you want to clean?: "
filename = gets.chomp
file = filename + '.csv'

print "What's the number of the column you want to de-dupe? "
column = gets.chomp.to_i - 1

written = Array.new
headers = Array.new
headers_set = false
dupe_counter = 0
unique_counter = 0

# split variables
division = 10000
counter = 0

clean_csv = CSV.open("full_cleaned_#{file}", "wb") 
dupes_csv = CSV.open("dupes_#{file}", "wb") 

puts "Removing duplicates..."

CSV.foreach(File.path(file)) do |col|
	if headers_set == false
		headers.push(col)
		dupes_csv << col.each { |i| [i.to_s] }
		headers_set = true
	end

	if ((col[column] != nil) && (written.include?(col[column])))
		dupes_csv << col.each { |i| [i.to_s] }
		dupe_counter += 1
	else
		clean_csv << col.each { |i| [i.to_s] }
		written.push(col[column])
		unique_counter += 1
	end

end

puts "Done. Found #{unique_counter} unique rows and #{dupe_counter} duplicate entries in column #{column + 1}."

clean_csv.close
dupes_csv.close

if unique_counter > 9999
	puts "Splitting into sets of 9999 rows..."

	# splitting now
	newcsv = CSV.open("#{filename}_#{counter}.csv", "wb") 
	CSV.foreach(File.path("full_cleaned_" + file)) do |col|
		counter += 1
		if (counter % division == 0)
			newcsv.close
			newcsv = CSV.open("#{filename}_#{counter / division}.csv", "wb") 
			headers.each { |i| newcsv << i }
		end
		
		newcsv << col.each { |i| [i.to_s] }
	end
	newcsv.close
end

puts "Okay, you\'re all done then."
