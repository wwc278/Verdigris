#! /usr/bin/env ruby

class House
  attr_accessor :number, :color, :nationality, :drink, :smoke, :pet
  @@houses = []

  def initialize
    @@houses << self
  end

  def self.find(keyword)
    #find the house by keyword (e.g. House.find("japanese"))
    @@houses.each do |house|
      attribute = $key_words_hash[keyword]
      return house if house.send(attribute) == keyword
    end
    return nil
  end
end

def create_keywords_hash
    position_words_arr = ['first', 'middle', 'right', 'next']
    color_words_arr = ['yellow', 'blue', 'red', 'ivory', 'green']
    nationality_words_arr = 
    ['norwegian', 'ukrainian', 'englishman', 'spaniard', 'japanese']
    drink_words_arr = ['tea', 'milk', 'orange', 'coffee']
    smoke_words_arr = 
    ['kools', 'chesterfields', 'old', 'lucky', 'parliaments']
    pet_words_arr = ['fox', 'horse', 'snails', 'dog']

    $key_words_hash = Hash.new(false)

    [position_words_arr, color_words_arr, nationality_words_arr, drink_words_arr, smoke_words_arr, pet_words_arr].each_with_index do 
      |array, idx|

      attributes = [:number, :color, :nationality, :drink, :smoke, :pet]
      array.each do |word|
        $key_words_hash[word] = attributes[idx]
      end
    end
    $key_words_hash
  end

class Solution
  def initialize
    @houses = []
  end

  def render_solution
    @houses.each do |house|
      p house
    end
  end

  def parse_puzzle_constraints
    simple_relations = {}
    next_relations = {}
    right_relations = {}

    File.open('puzzle_constraints.txt').each_line do |line|
      matched_words = []
      line.chomp[0...-1].split(" ").each do |word|
        matched_words << word if @key_words_hash[word.downcase]
      end

      if matched_words.length == 2
        simple_relations[matched_words.first] = matched_words.last
      elsif matched_words.include?("next")
        next_relations[matched_words.first] = matched_words.last
      elsif matched_words.include?("right")
        right_relations[matched_words.first] = matched_words.last
      end

    end

    p simple_relations, next_relations, right_relations
  end

end


create_keywords_hash

# h = House.new
# h.color = 'red'
# h2 = House.new
# h2.color = 'blue'
# p House.find('red')

# s = Solution.new
# s.parse_puzzle_constraints
# s.render_solution

#script to run algorithm
