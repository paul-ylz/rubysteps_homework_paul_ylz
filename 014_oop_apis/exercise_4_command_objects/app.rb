require 'date'

class AddFoodEntryCommand
  def initialize(meal, food)
    @meal = meal
    @food = food
  end

  def execute
    TrackerWriteService.add_food_entry @meal, @food
  end
end

class ReportEntriesCommand
  def initialize(date)
    @date = date
  end

  def execute
    TrackerReadService.report @date
  end
end

class AddExerciseEntryCommand
  def initialize(exercise)
    @exercise = exercise
  end

  def execute
    TrackerWriteService.add_exercise_entry @exercise
  end
end

class UsageNotesCommand
  def execute
    $stderr.puts <<END
Usage:

# report entire daily tracker
ruby app.rb r

# a single day's report
ruby app.rb r 2014-08-04

# add a food entry (b = breakfast, l = lunch, d = dinner)
ruby app.rb a f l "ham and eggs"

# add an exercise entry (not yet implemented)
ruby app.rb a e "kettlebell swings"
END
  end
end

class TrackerReadService
  def self.report(date=nil)
    tracker = DailyTracker.new
    DatabaseService.load_tracker tracker

    puts tracker.report(@date).join("\n\n====\n\n")
  end
end

class TrackerWriteService
  def self.add_food_entry(meal, food)
    tracker = DailyTracker.new
    DatabaseService.load_tracker tracker

    tracker.add_food_entry meal, food
    DatabaseService.save_tracker tracker
  end

  def self.add_exercise_entry(exercise)
    tracker = DailyTracker.new
    DatabaseService.load_tracker tracker

    tracker.add_exercise_entry exercise
    DatabaseService.save_tracker tracker
  end
end

class DatabaseService
  def self.load_tracker(tracker)
    db = Database.new('trackerdb.txt')
    tracker.load_from db
  end

  def self.save_tracker(tracker)
    db = Database.new('trackerdb.txt')
    tracker.save_to db
  end
end

class InputHandler
  def handle(input)
    case input.first
    when 'r'
      date = Date.parse(input.last) rescue nil
      TrackerReadService.report(date)
    when 'a'
      TrackerWriteService.add_food_entry(*input[2..-1])
    else
      ApplicationHelpService.usage_notes
    end
  end
end

class DailyTracker
  def report(date = nil)
    entries_for_date(date).inject([]) do |report_lines, day_entries|
      report_lines << build_report_line(day_entries)
    end
  end

  def add_food_entry(meal, food)
    @new_entry = ['f', meal, food, Date.today.to_s]
  end

  def add_exercise_entry(exercise)
    @new_entry = ['e', exercise, Date.today.to_s]
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
    group_entries_by_date
    group_entries_by_type
    order_food_entries
    entries_ordered_by_date
  end

  private

  def group_entries_by_date
    @entries_by_date = @entries.group_by(&:last)
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
