require './ex2_refactoring_birthday_tracker'

db_filename = 'birthdays.txt'
File.open(db_filename, 'w') { }

app = BirthdayTracker.new db_filename

app.new_entry('Marisa', 11, 'Jan', 1900)
app.new_entry('Justin', 12, 'Feb', 1900)
app.new_entry('Shaun', 13, 'Mar', 1900)
app.new_entry('Winnie', 30, 'Apr', 1900)
app.new_entry('Tor', 12, 'May', 1900)
app.update_entry('Justin', ['Justinia', 12, 'Feb', 1900])
app.show_entry('Tor')
app.show_entry('Tora')
app.delete_entry('Winnie')
app.dump
