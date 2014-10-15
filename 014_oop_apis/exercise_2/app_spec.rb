$:.unshift '.'
require 'app'

describe 'DailyTrackerApp' do
  let(:db_filename) { 'test_db.txt' }
  let(:db) { Database.new db_filename }
  let(:app) { DailyTrackerApp.build db_filename }

  before do
    File.open(db_filename, 'w') { |f| f.truncate 0 }
  end

  describe 'adding foods' do
    it 'adds meals by the #run() interface' do
      app.run ['a', 'f', 'l', 'ham and eggs']
      expect(db.entries.length).to eq 1
      expect(db.entries[0][2]).to eq 'ham and eggs'
    end

    it 'adds meals by the #add_food_entry() interface' do
      app.add_food_entry 'l', 'chicken curry'
      expect(db.entries.length).to eq 1
      expect(db.entries[0][2]).to eq 'chicken curry'
    end
  end

  describe 'adding exercises' do
    it 'adds meals by the #run() interface' do
      app.run ['a', 'e', 'push ups']
      expect(db.entries.length).to eq 1
      expect(db.entries[0][1]).to eq 'push ups'
    end

    it 'adds exercises by the #add_exercise_entry() interface' do
      app.add_exercise_entry 'hammerjack starjumps'
      expect(db.entries.length).to eq 1
      expect(db.entries[0][1]).to eq 'hammerjack starjumps'
    end
  end

  describe 'reporting' do

    before do
      @fake_log = <<END
f:l:waffles and ice cream:2014-10-13
f:d:blue cheese steak:2014-10-13
e:cycle 1 hour:2014-10-13
f:l:birthday cake:2014-10-14
f:d:pad kra pao with fried egg:2014-10-14
e:zumba 1 hour:2014-10-14
f:l:ham and eggs:2014-10-15
f:d:tuna salad:2014-10-15
e:starjumps:2014-10-15
END

      @expected_report = <<END
2014-10-13
waffles and ice cream
blue cheese steak
cycle 1 hour

====

2014-10-14
birthday cake
pad kra pao with fried egg
zumba 1 hour

====

2014-10-15
ham and eggs
tuna salad
starjumps
END

      File.open(db_filename, 'w') do |f|
        @fake_log.lines.shuffle.each { |line| f.puts line}
      end
    end

    it "reports all entries from #run(['r'])" do
      expect { app.run ['r'] }.to output(@expected_report).to_stdout
    end

    it "reports a single day's entries from #run(['r', date])" do
      expect { app.run ['r', '2014-10-15'] }.to output("2014-10-15\nham and eggs\ntuna salad\nstarjumps\n").to_stdout
    end
  end

end

# Notes
# Interface inconsistency: run needs an array, add_food_entry takes separate string arguments
# Opportunity for polymorphism: can the entry type be deciphered from the method name?
