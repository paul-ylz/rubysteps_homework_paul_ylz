$:.unshift '.' # add current dir to the require path
require 'app'

AddFoodEntryCommand.new("l", "ham and eggs").execute
AddFoodEntryCommand.new("d", "tuna salad").execute
AddExerciseEntryCommand.new("100 pushups").execute
ReportEntriesCommand.new(Date.today.to_s).execute
UsageNotesCommand.new.execute
