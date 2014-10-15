require 'date'

class DailyTrackerApp
  def initialize(tracker, handler, db)
    @tracker     = tracker
    @handler     = handler
    @handler.app = self
    @db          = db
  end

  def self.build(db_filename)
    tracker = DailyTracker.new
    handler = InputHandler.new
    db      = Database.new(db_filename)

    new tracker, handler, db
  end

  def run(input=ARGV)
    @tracker.load_from @db
    @handler.handle input
  end

  def report(date)
    puts @tracker.report(date).join("\n\n====\n\n")
  end

  def add_entry(entry_details)
    @tracker.add_entry entry_details
    @tracker.save_to @db
  end

  def add_food_entry(meal, food)
    @tracker.add_entry ['f', meal, food]
    @tracker.save_to @db
  end

  def add_exercise_entry(exercise)
    @tracker.add_entry ['e', exercise]
    @tracker.save_to @db
  end

  def usage_notes
    $stderr.puts usage_notes_string
  end

  private
  def usage_notes_string
<<END
Usage:

# report entire daily tracker
ruby app.rb r

# a single day's report
ruby app.rb r 2014-08-04

# add a food entry (b = breakfast, l = lunch, d = dinner)
ruby app.rb a f l "ham and eggs"

# add an exercise entry
ruby app.rb a e "kettlebell swings"
END
  end
end

class InputHandler
  attr_writer :app

  def handle(input)
    case input.first
    when 'r'
      date = Date.parse(input.last) rescue nil
      @app.report date
    when 'a'
      @app.add_entry(input[1..-1])
    else
      @app.usage_notes
    end
  end
end

class DailyTracker
  def report(date = nil)
    entries_for_date(date).inject([]) do |report_lines, day_entries|
      report_lines << build_report_line(day_entries)
    end
  end

  def add_entry(entry_details)
    @new_entry = entry_details << Date.today.to_s
  end

  def load_from(db)
    entries.clear
    db.entries.each {|e| load_entry e }
  end

  def save_to(db)
    if @new_entry
      db.write_entry @new_entry
      @new_entry = nil
    end
  end

  private

  def entries
    @entries ||= []
  end

  def load_entry(entry)
    entries << entry
  end

  def entries_for_date(date)
    EntryList.new(@entries).for_date(date)
  end

  def build_report_line(day_entries)
    report_line = [day_entries.first]
    report_line += day_entries.last['f'].map {|e| e[2] }
    report_line += day_entries.last['e'].map {|e| e[1] }
    report_line.join("\n")
  end
end

class EntryList
  def initialize(entries)
    @entries = entries
  end

  def for_date(date)
    group_entries_by_date(date)
    group_entries_by_type
    order_food_entries
    entries_ordered_by_date
  end

  private

  def group_entries_by_date(date)
    @entries_by_date = @entries.group_by(&:last)
    unless date.nil?
      @entries_by_date.select! { |d, e| d == date.to_s }
    end
  end

  def group_entries_by_type
    @entries_by_date.each do |key, entries|
      @entries_by_date[key] = entries.group_by(&:first)
    end
  end

  def order_food_entries
    @entries_by_date.values.each do |entries|
      if food_group = entries['f']
        food_group.sort_by! {|f| %w(b l d).index(f[1]) }
      end
    end
  end

  def entries_ordered_by_date
    @entries_by_date.keys.sort.inject([]) do |sorted_entries, key|
      sorted_entries << [key, @entries_by_date[key]]
    end
  end
end

class Database
  def initialize(filename)
    @filename = File.expand_path(filename)
  end

  def entries
    return [] unless File.file?(@filename)

    File.readlines(@filename).map(&:strip).map {|s| s.split(':') }
  end

  def write_entry(new_entry)
    File.open(@filename, 'a+') {|f| f << new_entry.join(":") << "\n" }
    true
  end
end
