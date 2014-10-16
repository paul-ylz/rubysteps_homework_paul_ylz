# Ex 1 horrible code

def new_birthday_entry
  puts "Name?"
  name = gets.chomp
  puts "Month?"
  month = gets.chomp
  puts "Day?"
  date = gets.chomp

  entry = [name, month, date]
  true if save(entry)
end

def save(entry)
  File.open('birthdays.txt', 'a+') do |file|
    file << entry.join(':') << "\n"
  end
end

def get(name)
  unless db_get(name).nil?
    puts db_get(name).strip
  end
end

def db_get(name)
  entry = ''
  File.open('birthdays.txt', 'a+') do |file|
    file.each_line do |line|
      entry = line if line.include? name
    end
  end
  entry
end

def edit(name)
  unless db_get(name).nil?
    puts db_get(name).strip
    puts 'Edit entry? (y/n)'
    answer = gets.chomp
    case answer
    when 'y'
      puts "Replace entry with new information:"
      if new_birthday_entry
        delete_entry(name)
      end
    when 'n'
      nil
    end
  end
end

def delete_entry(name)
  all_entries = []
  File.open('birthdays.txt', 'r') do |f|
    all_entries = f.each_line.to_a
  end
  all_entries.delete db_get(name)

  File.open('birthdays.txt', 'w') do |file|
    all_entries.each { |entry| file << entry }
  end
end
