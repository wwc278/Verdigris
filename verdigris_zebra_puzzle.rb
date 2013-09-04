#! /usr/bin/env ruby

class House
  attr_accessor :position, :color, :nationality, :drink, :smoke, :pet

end

def parse_puzzle_constraints
  position_words_arr = ['first', 'middle']
  nationality_words_arr = 
    ['norweigian', 'ukrainian', 'englishman', 'spaniard', 'japanese']

  key_words_hash = 
  puzzle_constraints = []
  File.open('puzzle_constraints.txt').each_line do |line|
    puzzle_constraints << line.chomp
  end

  puzzle_constraints.each do |line|

  end
end



h = House.new
h.color = :red

h.drink = :milk
h.smoke = :lucky_strike
h.pet = :zebra
h.nationality = :englishman
p h

parse_puzzle_constraints

#script to run algorithm
