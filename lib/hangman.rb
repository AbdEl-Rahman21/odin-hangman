# frozen_string_literal: true

require 'rainbow'

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

  attr_reader :word
  attr_accessor :guesses, :blank_word, :remaining_guesses

  def intro
    system('clear')

    puts "\t\t== Open for business 3.0 =="
    print Rainbow('[1]').color(:blue)
    puts "\sPlay new game."
    print Rainbow('[2]').color(:blue)
    puts "\sLoad old game."
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

  def get_word
    File
      .readlines('10000_english.txt', chomp: true)
      .filter { |word| true if word.length >= 5 && word.length <= 12 }
      .sample
  end

  def save_game; end

  def load_game; end

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

  def invalid_input?(choice)
    if choice.length != 1 || !choice.match?(/[[:alpha:]]/) ||
       guesses.include?(choice)
      true
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

  def get_choice
    loop do
      choice = gets.chomp

      return choice if %w[1 2].include?(choice)

      puts 'Error: Invalid Input.'
    end
  end

  def setup
    @word = get_word.split('')
    @guesses = []
    @remaining_guesses = 10
    @blank_word = Array.new(word.length, '_')
  end
end

Game.new.create_game
