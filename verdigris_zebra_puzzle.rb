#! /usr/bin/env ruby

require 'debugger'

$position_words_arr = ['first', 'middle', 'right', 'next']
$color_words_arr = ['yellow', 'blue', 'red', 'ivory', 'green']
$nationality_words_arr = 
['norwegian', 'ukrainian', 'englishman', 'spaniard', 'japanese']
$drink_words_arr = ['tea', 'milk', 'orange', 'coffee', 'water']
$smoke_words_arr = 
['kools', 'chesterfields', 'old', 'lucky', 'parliaments']
$pet_words_arr = ['fox', 'horse', 'snails', 'dog', 'zebra']

$keywords_hash = Hash.new(false)

[$position_words_arr, $color_words_arr, $nationality_words_arr, $drink_words_arr, $smoke_words_arr, $pet_words_arr].each_with_index do 
  |array, idx|

  $attributes = [:position, :color, :nationality, :drink, :smoke, :pet]
  array.each do |word|
    $keywords_hash[word] = $attributes[idx]
  end
end
$keywords_hash


class House
  attr_accessor :position, :color, :nationality, :drink, :smoke, :pet
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
    @final_ordered_houses = Array.new(5) {|el| House.new}

  end

  def render_solution
    puts ""
    puts "final solution:"
    render_str = ""
    @final_ordered_houses.each do |house|
      $attributes.each do |attribute|
        if house.send(attribute).nil?
          render_str += "nil, "
        else
          render_str += house.send(attribute) + ", "
        end
      end
      render_str += "\n"
    end
    puts render_str
  end

  def parse_puzzle_constraints
    @simple_relations = {}
    @next_relations = {}
    @right_relations = {}
    @pos_relations = {}
    @no_relations = []

    File.open('puzzle_constraints.txt').each_line do |line|
      matched_words = []
      line.chomp[0...-1].split(" ").each do |word|
        matched_words << word.downcase if $keywords_hash[word.downcase]
      end

      if matched_words.include?("middle") || matched_words.include?("first")
        @pos_relations[matched_words.first] = matched_words.last
      elsif matched_words.include?("next")
        # map relations both ways to allow for reverse look-up
        @next_relations[matched_words.first] = matched_words.last
        @next_relations[matched_words.last] = matched_words.first
      elsif matched_words.include?("right")
        @right_relations[matched_words.first] = matched_words.last
      elsif matched_words.length == 2
        # map relations both ways to allow for reverse look-up
        @simple_relations[matched_words.first] = matched_words.last
        @simple_relations[matched_words.last] = matched_words.first
      end

    end

    # unassociated words in @no_relations
    $keywords_hash.keys.each do |key|
      if !@simple_relations[key] && key != "right" && key != "next"
        @no_relations << key
      end
    end

    # puts "simple_relations: #{@simple_relations}"
    # puts ""
    # puts "next_relations: #{@next_relations}"
    # puts ""
    # puts "right_relations: #{@right_relations}"
    # puts ""
    # puts "pos_relations: #{@pos_relations}"
    # puts ""
    # puts "no_relations: #{@no_relations}"
    # puts ""

    [@simple_relations, @next_relations, @right_relations, @pos_relations]
  end

  def deduce_from_simple_relations
    @final_ordered_houses.each do |house|
      next if house.nil? #nothing to deduce if there are no attributes

      $attributes.each do |attribute|
        key = house.send(attribute)
        value = @simple_relations[key]
        value_attr = $keywords_hash[value]
        if value && house.send(value_attr).nil?
          house.send(value_attr.to_s + "=", value)
        end
      end
    end
  end

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

    @final_ordered_houses[1].position = "second"
    @final_ordered_houses[3].position = "fourth"
    @final_ordered_houses[4].position = "last"
  end

  def make_deductions
    7.times do
      create_from_pos_relations
      place_next_relations
      deduce_colors
      deduce_from_simple_relations
      deduce_drinks
      deduce_smokes
      deduce_pets
      deduce_from_singling_and_pairing
    end
  end

  def place_next_relations
    # go through "next relations" (e.g. norwegian next to blue house)
    @next_relations.each do |key, value|
      curr_house = House.find(key) if House.exist?(key)

      if curr_house
        attribute = $keywords_hash[value].to_s

        if curr_house.position == "first"
          second_house = @final_ordered_houses[1] || House.new
          second_house.position = "second" unless second_house.position
          second_house.send(attribute + "=", value)
          @final_ordered_houses[1] = second_house

        elsif curr_house.position == "last"
          fourth_house = @final_ordered_houses[3] || House.new
          fourth_house.position = "fourth" unless fourth_house.position
          fourth_house.send(attribute + "=", value)
          @final_ordered_houses[3] = fourth_house
        end

      end
    end
  end



  [$position_words_arr, $color_words_arr, $nationality_words_arr, $drink_words_arr, $smoke_words_arr, $pet_words_arr].each_with_index do |arr, idx|
    attribute = $attributes[idx].to_s
    define_method("available_" + attribute) do 
      avail_attr = []
      arr.each do |el|
        avail_attr << el unless House.exist?(el)
      end
      avail_attr
    end
  end

  #use meta-programming to reduce number of unique deduce methods
  [:deduce_numbers, :deduce_colors, :deduce_nationalities, :deduce_drinks, :deduce_smokes, :deduce_pets].each_with_index do |method_name, idx|
    attribute = $attributes[idx].to_s
    define_method(method_name) do 
      @final_ordered_houses.each do |house|
        next if house.nil? # only try to deduce if the house has some info

        #maps attr to boolean (e.g. yellow => false)
        deduction_hash = {} 

        if house.send(attribute).nil? #try to deduce attr (e.g. color) if house has no attr (e.g. color)
          self.send("available_" + attribute).each do |el|
            house.send(attribute + "=", el) # try the attr (e.g. color)

            # record if it violates any relations
            deduction_hash[el] = violates_relations?

            house.send(attribute + "=", nil) # set back to nil
          end
        end

        # check if only one key is false (meaning it is the only one that does not violate relations), if so, set the house attr (e.g. color) to that value

        if deduction_hash.values.one? {|el| el == false}
          house.send(attribute + "=", deduction_hash.key(false))
        end
      end

    end
  end

  # Keeping the original deduce_colors method here as a template, this method is essentially repeated many times to deduce all the different categories

  # def available_color
  #   avail_colors = []
  #   $color_words_arr.each do |color|
  #     avail_colors << color unless House.exist?(color)
  #   end
  #   avail_colors
  # end

  # def deduce_colors
  #   @final_ordered_houses.each do |house|
  #     next if house.nil? # only try to deduce color if the house has some info
  #     #maps color to boolean (e.g. yellow => false)
  #     deduction_hash = {} 

  #     if house.color.nil? #try to deduce color if house has no color
  #       available_colors.each do |color|
  #         house.color = color
  #         deduction_hash[color] = violates_relations?
  #         house.color = nil
  #       end
  #     end

  #     # check if only one key is false (meaning it is the only one that does not violate relations), if so, set the house color to that color
  #     if deduction_hash.values.one? {|el| el == false}
  #       house.color = deduction_hash.key(false)
  #     end
  #   end
  # end

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
        return true if violates_next_relations?

        #check if it violates right relations
        return true if violates_right_relations?
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

  def violates_next_relations?
    @next_relations.each do |key, value|
      if House.exist?(key) && House.exist?(value)
        curr_house = House.find(key)
        house_idx = @final_ordered_houses.index(curr_house)
        other_house = House.find(value)
        other_house_idx = @final_ordered_houses.index(other_house)

        return true if (house_idx - other_house_idx).abs > 1
      end
    end
    false
  end

  def violates_right_relations?
    #loop through all right relations, in this case it is unecessary because there is only one, but it allows for a different problem with multiple right relations to be solved
    @right_relations.each do |key, value|

      if House.exist?(key)
        curr_house = House.find(key)
        r_idx = @final_ordered_houses.index(curr_house)

        # true if "key" house (e.g green) is first
        if curr_house.position == 'first'
          return true
        else
          left_house = @final_ordered_houses[r_idx - 1] 
          # return true unless the left house is nil or has the correct color
          if !left_house.color.nil? && left_house.color != value
            return true
          end
        end
      end

      if House.exist?(value)
        curr_house = House.find(value)
        l_idx = @final_ordered_houses.index(curr_house)

        # true if "value" house (e.g. ivory) is last
        if curr_house.position == 'last'
          return true
        else
          right_house = @final_ordered_houses[l_idx + 1]
          # return true unless the right house is nil or has the correct color
          if !right_house.color.nil? && right_house.color != key
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

  def deduce_from_singling_and_pairing
    unknown_attribute_arr = []
    @final_ordered_houses.each do |house|
      next if house.nil?

      unknown_attributes = []
      $attributes.each do |attribute|
        unknown_attributes << attribute if house.send(attribute).nil?
      end

      deduce_from_singles(unknown_attributes, house)

      unknown_attribute_arr << unknown_attributes
    end

    deduce_from_pairs(unknown_attribute_arr)
    complex_deduction_with_singles(unknown_attribute_arr)
  end

  def complex_deduction_with_singles(unknown_attribute_arr)
    num_of_unknowns_arr = []
    unknown_attribute_arr.each do |arr|
      num_of_unknowns_arr << arr.length
    end

    single_attr_arr = []
    @no_relations.each do |el|
      single_attr_arr << el if !House.exist?(el)
    end

    # if only three houses have odd number unknowns and we have three single attributes
    num_of_unknowns_arr = num_of_unknowns_arr.map {|el| el % 2 == 1}
    if num_of_unknowns_arr.count(true) == 3 && single_attr_arr.length == 3
      num_of_unknowns_arr.each_with_index do |el, idx|
        next unless el # skip if even number of unknowns

        #custom deduction similar to the deduce_* method

        house = @final_ordered_houses[idx]
        #maps attr to boolean (e.g. yellow => false)
        unknown_attribute_arr[idx].each do |attribute|
          attribute = attribute.to_s
          deduction_hash = {} 
          
          single_attr_arr.each do |single_attr|
            if $keywords_hash[single_attr].to_s == attribute
              house.send(attribute + "=", single_attr)

              # record if it violates any relations
              deduction_hash[single_attr] = violates_relations?

              house.send(attribute + "=", nil) # set back to nil
            end


          end

          # slightly different reasoning, only set value if there is only one choice and it does not violate any relations
          if deduction_hash.values.one? {|el| el == false} && 
            deduction_hash.values.length == 1
            house.send(attribute + "=", deduction_hash.key(false))
          end
        end
      end
    end

  end

  def deduce_from_pairs(unknown_attribute_arr)
    #check each house for missing pair of attributes and that the attributes are unique in that array
    unknown_attribute_arr.each_with_index do |un_attr, idx|
      if un_attr.length == 2 && 
        unknown_attribute_arr.one? {|el| el == un_attr}
        pair_attr = find_pair_attributes(un_attr[0], un_attr[1])
        if pair_attr.length == 2
          house = @final_ordered_houses[idx]
          house.send(un_attr[0].to_s + "=", pair_attr.first)
          house.send(un_attr[1].to_s + "=", pair_attr.last)
        end
      end
    end
  end

  def deduce_from_singles(unknown_attributes, house)
    unknown_attributes.each do |un_attr|
      single_attr = find_single_attribute(un_attr)

      if (unknown_attributes.length == 3 || unknown_attributes.length == 1) && single_attr.length == 1
        house.send(un_attr.to_s + "=", single_attr.first)
      end
    end
  end

  def find_single_attribute(attribute)
    results = []
    @no_relations.each do |el|
      if $keywords_hash[el] == attribute && !House.exist?(el)
        results << el
      end
    end
    results
  end

  def find_pair_attributes(attr1, attr2)
    results = []
    @simple_relations.each do |key, value|
      if $keywords_hash[key] == attr1 && $keywords_hash[value] == attr2
        results << key << value
      end
    end
    results
  end
  
end

#script to run algorithm

s = Solution.new
s.parse_puzzle_constraints
s.make_deductions
s.render_solution
