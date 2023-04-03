# frozen_string_literal: true

require 'rainbow'
require 'yaml'

class Game
  def initialize
    setup
  end

  def create_game
    loop do
      intro

      play

      repeat
    end
  end

  private

  attr_accessor :guesses, :blank_word, :remaining_guesses, :word

  def setup
    @word = get_word.split('')
    @guesses = []
    @remaining_guesses = 10
    @blank_word = Array.new(word.length, '_')
  end

  def get_word
    File
      .readlines('10000_english.txt', chomp: true)
      .filter { |word| true if word.length >= 5 && word.length <= 12 }
      .sample
  end

  def intro
    system('clear')

    puts "\t\t== Open for business 3.0 =="
    puts "#{Rainbow('[1]').color(:blue)} Play new game."
    puts "#{Rainbow('[2]').color(:blue)} Load old game."

    load_game if get_choice == '2'
  end

  def get_choice
    loop do
      choice = gets.chomp

      return choice if %w[1 2].include?(choice)

      puts 'Error: Invalid Input.'
    end
  end

  def load_game
    puts Dir.glob('save_data/*.yaml')

    save = YAML.safe_load File.read("save_data/#{get_save_to_load}.yaml")

    self.word = save[:word]
    self.guesses = save[:guesses]
    self.remaining_guesses = save[:remaining_guesses]
    self.blank_word = save[:blank_word]
  end

  def get_save_to_load
    loop do
      print 'Enter save name: '

      save_name = gets.chomp

      return save_name if File.exist?("save_data/#{save_name}.yaml")

      puts "Error:Save doesn't exist."
    end
  end

  def play
    loop do
      layout

      play_turn

      if !blank_word.include?('_')
        puts 'You Win!'

        break
      elsif remaining_guesses.zero?
        puts "You Lose!\nThe word is: #{Rainbow(word.join.to_s).color(:blue)}"

        break
      end
    end
  end

  def play_turn
    letter = get_letter

    guesses.push(letter)

    if word.include?(letter)
      word.each_with_index { |e, i| blank_word[i] = letter if e == letter }
    else
      self.remaining_guesses -= 1
    end
  end

  def layout
    puts Rainbow("Remaining Guesses: #{remaining_guesses}").color(:yellow)

    blank_word.each { |letter| print Rainbow(letter.to_s).color(:blue) }

    print Rainbow("\tGuesses: ").color(:red)

    guesses.each do |letter|
      if word.include?(letter)
        print "#{Rainbow(letter.to_s).color(:blue)}\s"
      else
        print "#{Rainbow(letter.to_s).color(:red)}\s"
      end
    end

    print "\nEnter your guess or \"save\": "
  end

  def get_letter
    loop do
      choice = gets.chomp.downcase

      if choice == 'save'
        save_game
      elsif invalid_input?(choice)
        puts 'Error: Input must be 1 alphabetic character and not already guessed.'
      else
        return choice
      end
    end
  end

  def save_game
    Dir.mkdir('save_data') unless Dir.exist?('save_data')

    File.open("save_data/#{get_save_name}.yaml", 'w') do |file|
      file.puts YAML.dump(
        {
          word: word,
          guesses: guesses,
          remaining_guesses: remaining_guesses,
          blank_word: blank_word
        }
      )
    end

    exit
  end

  def get_save_name
    loop do
      print 'Enter save name: '

      save_name = gets.chomp

      return save_name unless File.exist?("save_data/#{save_name}.yaml")

      print 'Name is taken do you want to override it (Y\\N): '

      return save_name if override?
    end
  end

  def override?
    loop do
      case gets.chomp.downcase
      when 'y'
        return true
      when 'n'
        return false
      else
        puts 'Error:Invalid Input.'
      end
    end
  end

  def invalid_input?(choice)
    if choice.length != 1 || !choice.match?(/[[:alpha:]]/) ||
       guesses.include?(choice)
      true
    end
  end

  def repeat
    print Rainbow('[1]').color(:blue)
    puts "\sPlay again."
    print Rainbow('[2]').color(:blue)
    puts "\sExit."

    if get_choice == '1'
      setup
    else
      exit
    end
  end
end

Game.new.create_game
