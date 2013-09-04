#! /usr/bin/env ruby

require 'debugger'

def create_keywords_hash
  $position_words_arr = ['first', 'middle', 'right', 'next']
  $color_words_arr = ['yellow', 'blue', 'red', 'ivory', 'green']
  $nationality_words_arr = 
  ['norwegian', 'ukrainian', 'englishman', 'spaniard', 'japanese']
  $drink_words_arr = ['tea', 'milk', 'orange', 'coffee']
  $smoke_words_arr = 
  ['kools', 'chesterfields', 'old', 'lucky', 'parliaments']
  $pet_words_arr = ['fox', 'horse', 'snails', 'dog']

  $keywords_hash = Hash.new(false)

  [$position_words_arr, $color_words_arr, $nationality_words_arr, $drink_words_arr, $smoke_words_arr, $pet_words_arr].each_with_index do 
    |array, idx|

    $attributes = [:number, :color, :nationality, :drink, :smoke, :pet]
    array.each do |word|
      $keywords_hash[word] = $attributes[idx]
    end
  end
  $keywords_hash
end

class House
  attr_accessor :number, :color, :nationality, :drink, :smoke, :pet
  @@houses = []

  def initialize
    #TODO: create mass assignment?
    @@houses << self
  end

  def self.find(keyword)
    attribute = $keywords_hash[keyword]
    @@houses.each do |house|
      return house if house.send(attribute) == keyword
    end
    nil
  end

  def self.find_or_create(keyword)
    #find the house by keyword (e.g. House.find("japanese"))
    attribute = $keywords_hash[keyword].to_s
    @@houses.each do |house|
      return house if house.send(attribute) == keyword
    end
    
    new_house = House.new
    new_house.send(attribute + "=", keyword)
    return new_house
  end

  def self.exist?(keyword)
    # reveal if a house with an attribute "red" exists
    attribute = $keywords_hash[keyword]
    @@houses.each do |house|
      return true if house.send(attribute) == keyword
    end
    false
  end

  def self.can_merge?(house1, house2)
    $attributes.each do |el|
      return false if house1.send(el) && house2.send(el)
    end
    true
  end

  def self.merge(house1, house2)
    new_house = House.new
    $attributes.each do |attribute|
      h1_attr = house1.send(attribute)
      h2_attr = house2.send(attribute)
      if h1_attr
        new_house.send(attribute.to_s + "=", h1_attr)
      elsif h2_attr
        new_house.send(attribute.to_s + "=", h2_attr)
      end
    end
    new_house
  end
end



class Solution
  def initialize
    @final_ordered_houses = Array.new(5)
  end

  def render_solution
    puts ""
    puts "final solution:"
    @final_ordered_houses.each do |house|
      p house
    end
  end

  def parse_puzzle_constraints
    @simple_relations = {}
    @next_relations = {}
    @right_relations = {}
    @pos_relations = {}

    File.open('puzzle_constraints.txt').each_line do |line|
      matched_words = []
      line.chomp[0...-1].split(" ").each do |word|
        matched_words << word.downcase if $keywords_hash[word.downcase]
      end

      if matched_words.include?("middle") || matched_words.include?("first")
        @pos_relations[matched_words.first] = matched_words.last
      elsif matched_words.include?("next")
        @next_relations[matched_words.first] = matched_words.last
      elsif matched_words.include?("right")
        @right_relations[matched_words.first] = matched_words.last
      elsif matched_words.length == 2
        # map relations both ways to allow for reverse look-up
        @simple_relations[matched_words.first] = matched_words.last
        @simple_relations[matched_words.last] = matched_words.first
      end

    end

    puts "simple_relations: #{@simple_relations}"
    puts ""
    puts "next_relations: #{@next_relations}"
    puts ""
    puts "right_relations: #{@right_relations}"
    puts ""
    puts "pos_relations: #{@pos_relations}"
    puts ""

    [@simple_relations, @next_relations, @right_relations, @pos_relations]
  end

  # def create_from_simple_relations #possibly unneeded 
  #   @simple_relations.each do |key, value|
  #     curr_house = House.find_or_create(key)
  #     unless curr_house
  #       curr_house = House.new
  #       attribute = $keywords_hash[key].to_s
  #       curr_house.send(attribute + "=", key)
  #       @houses << curr_house
  #     end

  #     attribute = $keywords_hash[value].to_s
  #     curr_house.send(attribute + "=", value)
  #   end
  # end

  def create_from_pos_relations
    @pos_relations.each do |key, value|
      curr_house = House.find_or_create(key)


      attribute = $keywords_hash[value].to_s
      if value == "middle"
        curr_house.send(attribute + "=", "middle")
        @final_ordered_houses[2] = curr_house
      elsif value == "first"
        curr_house.send(attribute + "=", "first")
        @final_ordered_houses[0] = curr_house
      end
    end
  end

  def make_deductions
    create_from_pos_relations
    place_next_relations
    deduce_color
  end

  def place_next_relations
    # go through "next relations" (e.g. norwegian next to blue house)
    @next_relations.each do |key, value|
      curr_house = House.find(key) if House.exist?(key)

      if curr_house
        new_house = House.new
        attribute = $keywords_hash[value].to_s

        if curr_house.number == "first"
          new_house.number = "second"
          new_house.send(attribute + "=", value)
          @final_ordered_houses[1] = new_house
        elsif curr_house.number == "last"
          new_house.number = "fourth"
          new_house.send(attribute + "=", value)
          @final_ordered_houses[3] = new_house
        end

      end
    end
  end

  def available_colors
    avail_colors = []
    $color_words_arr.each do |color|
      avail_colors << color unless House.exist?(color)
    end
    avail_colors
  end

  def deduce_color
    @final_ordered_houses.each do |house|
      next if house.nil? # only try to deduce color if the house has some info
      bool_arr = []

      if house.color.nil? #try to deduce color if house has no color
        available_colors.each do |color|
          house.color = color
          p house, violates_relations?

          bool_arr << violates_relations?
          house.color = nil
        end
      end
      p bool_arr
    end
  end

  def violates_relations?
    @final_ordered_houses.each do |house|
      next unless house #skip if house is nil
      $attributes.each do |attribute|
        keyword = house.send(attribute)
        # skip if attribute is nil (e.g. house.color returns nil)
        next unless keyword

        #check if it violates simple relations
        return true if violates_simple_relations?(keyword)

        #check if it violates next relations
        return true if violates_right_relations?

        #check if it violates right relations

      end
    end
    false
  end

  def violates_simple_relations?(keyword)
    matching_keyword = @simple_relations[keyword]
    # if matching_keyword is nil, return false (i.e. keyword is not a simple relation)
    return false unless matching_keyword

    # if house with keyword exists, find the house and compare the matching attribute to the matching keyword

    if House.exist?(keyword)
      curr_house = House.find(keyword)
      attribute = $keywords_hash[matching_keyword]
      return false if curr_house.send(attribute).nil?
      return true unless curr_house.send(attribute) == matching_keyword
    end
    false
  end
end

def violates_right_relations?
  #loop through all right relations, in this case it is unecessary because there is only one, but it allows for a different problem with multiple right relations to be solved
  @right_relations.each do |key, value|

    if House.exist?(key)
      curr_house = House.find(key)
      r_idx = @final_ordered_houses.index(curr_house)

      # true if "key" house (e.g green) is first
      if curr_house.number == 'first'
        return true
      else
        left_house = @final_ordered_houses[r_idx - 1] 
        # return true unless the left house is nil or has the correct color
        unless left_house.nil? || left_house.color == value
          return true
        end
      end
    end

    if House.exist?(value)
      curr_house = House.find(value)
      l_idx = @final_ordered_houses.index(curr_house)

      # true if "value" house (e.g. ivory) is last
      if curr_house.number == 'last'
        return true
      else
        right_house = @final_ordered_houses[l_idx + 1]
        # return true unless the right house is nil or has the correct color
        unless right_house.nil? || right_house.color == key
          return true
        end
      end
      
    end

    # true if index of key house minus index of value house is greater than 1
    if House.exist?(key) && House.exist?(value)
      house_r = House.find(key)
      house_l = House.find(value)
      r_idx = @final_ordered_houses.index(house_r)
      l_idx = @final_ordered_houses.index(house_l)
      return true if r_idx - l_idx > 1
    end
  end
  false
end

#script to run algorithm

create_keywords_hash

s = Solution.new
s.parse_puzzle_constraints
s.make_deductions
s.render_solution

# work on parsing the next and right relations
# might have to iterate through random choices to continue with the algorithm