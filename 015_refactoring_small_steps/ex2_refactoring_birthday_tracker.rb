# Ex 2 refactor gently
class BirthdayTracker

  def initialize(db_filename)
    @entries = []
    @db_file = db_filename
    load_entries()
  end

  def load_entries
    File.open(@db_file, 'a+') do |file|
      file.each_line do |line|
        name, month, date = line.split(':')
        @entries << [name, month, date]
      end
    end
  end

  def save
    File.open(@db_file, 'w') do |file|
      @entries.each { |entry| file.puts entry.join(':')}
      true
    end
  end

  def new_entry(name, day, month, year)
    entry = [name, day, month, year]
    @entries << entry
    puts "#{entry} has been saved." if save
  end

  def show_entry(name)
    entry = @entries.select { |entry| entry[0].downcase == name.downcase }.first

    unless entry.nil?
      name, month, date = entry[0], entry[1], entry[2]
      puts "#{name}'s birthday is on #{month} #{date}."
    else
      puts "Sorry, '#{name}' was not found."
    end
  end

  def update_entry(name, entry)
    obsolete_entry = find_entry(name)
    delete_entry(name, silent: true)
    @entries << entry
    puts "#{obsolete_entry} has been updated to #{entry}"
  end

  def delete_entry(name, options={})
    obsolete_entry = find_entry(name)
    @entries.delete obsolete_entry
    if save
      unless options[:silent] == true
        puts "#{obsolete_entry} has been deleted."
      end
    end
  end

  def find_entry(name)
    @entries.select { |entry| entry[0].downcase == name.downcase }.first
  end

  def dump
    @entries.each { |entry| p entry }
  end
end
