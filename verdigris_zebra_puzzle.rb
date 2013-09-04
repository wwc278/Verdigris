#! /usr/bin/env ruby

class House
  attr_accessor :number, :color, :nationality, :drink, :smoke, :pet

  def self.find(keyword)
    #find the house by keyword (e.g. House.find("japanese"))
  end

end

class Solution
  def initialize
    @houses = []
    create_keywords_hash
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

    @key_words_hash = Hash.new(false)

    [position_words_arr, color_words_arr, nationality_words_arr, drink_words_arr, smoke_words_arr, pet_words_arr].each_with_index do 
      |array, idx|

      attributes = [:number, :color, :nationality, :drink, :smoke, :pet]
      array.each do |word|
        @key_words_hash[word] = attributes[idx]
      end
    end
    p @key_words_hash
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
      line.chomp[0..-2].split(" ").each do |word|
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


s = Solution.new
# s.parse_puzzle_constraints
# s.render_solution

#script to run algorithm
