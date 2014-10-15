$:.unshift '.'
require 'app'

app = DailyTrackerApp.build 'dev_db.txt'
app.run []
app.run ["r"]
app.run ["a", "f", "l", "ham and eggs"]
app.run ["a", "f", "d", "tuna salad"]
app.run ["r"]
