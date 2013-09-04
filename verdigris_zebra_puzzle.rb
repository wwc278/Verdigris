#! /usr/bin/env ruby

class House
  attr_accessor :position, :color, :nationality, :drink, :smoke, :pet

end

class Solution
  def initialize
    @houses = {}
    5.times do |idx|
      @houses[idx] = House.new 
    end
  end

  def render_solution
    @houses.each_value do |house|
      p house
    end
  end

  def parse_puzzle_constraints
    position_words_arr = ['first', 'middle', 'right', 'next']
    nationality_words_arr = 
    ['norweigian', 'ukrainian', 'englishman', 'spaniard', 'japanese']
    drink_words_arr = ['tea', 'milk', 'orange', 'coffee']
    smoke_words_arr = 
    ['kools', 'chesterfield', 'old gold', 'lucky', 'parliament']
    pet_words_arr = ['fox', 'horse', 'snails', 'dog']

    key_words_hash = Hash.new(false)

    [position_words_arr, nationality_words_arr, drink_words_arr, smoke_words_arr, pet_words_arr].each do |array|

      array.each do |word|
        key_words_hash[word] = true
      end
    end

    
    p key_words_hash

    File.open('puzzle_constraints.txt').each_line do |line|

    end

  end
end


s = Solution.new
s.parse_puzzle_constraints
s.render_solution

#script to run algorithm
