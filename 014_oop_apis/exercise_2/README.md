# Notes

### Interface inconsistency:
App#run() takes an array, but App#add_food_entry() takes separate string arguments. Is this what Pat means regarding consistency of an interface?

### Opportunity for polymorphism:
How about having a single add_entry method can the entry type be deciphered from the method name? Maybe apply #method_missing() ?

### Increasing explicity and usefulness:
- Should be able to supply date as an argument to a new entry
