#INSTRUCTIONS: if rspec is not installed, run gem install rspec
require 'rspec'

class PigLatin
  VOWELS = ["a","e","i","o","u"] #"y" at the beginning of a word isn't a vowel

  def self.translate(words)
    words_array = words.split(" ")
    new_words_array = []
    word_capitalized, word, non_word_part = nil

    add_new_word = Proc.new do
      word[0] = word[0].upcase if word_capitalized
      new_words_array << word + non_word_part
    end

    words_array.each do |unfiltered_word|
      word = unfiltered_word.match(/[-\w'*&]+/m).to_s#remove punctuation (but leave the possibility of words with apostrophe, dash, asterisk, or ampersand);

      #Note: this algorithm will not handle 'words' like "www.google.com" it will assume anything starting with the dot is punctuation and will turn the word into ooglegay.com

      non_word_part = unfiltered_word.gsub(word,"")

      if word[0].upcase == word[0]
        word_capitalized = true
        word[0] = word[0].downcase
      else
        word_capitalized = false
      end

      word.each_char.with_index do |letter, index|
        if VOWELS.include?(letter.downcase)
          if index == 0
            word = word + "way"
          elsif letter.downcase == "u" && word[index - 1] == "q"#"qu" is always moved together
            if index == word.length - 1
              word = "word" + "ay"#if word ends with qu and has no prior vowels then just add "ay"
            else
              word = word[index + 1 .. -1] + word[0 .. index] + "ay"
              #moved consants with the first encountered "qu" to the end and add "ay"
            end
          else
            word = word[index .. - 1] + word[0 .. index - 1] + "ay"
            #move consants before first encountered vowel to end of word and add "ay"
          end
          add_new_word.call
          break#after a vowel is encountered stop going through the word
        end
        if index == word.length - 1#if no vowels are found in the word (not a realistic example, but the algorithm can still handle this)
          word = word + "ay"
          add_new_word.call
        end
      end
    end
    return new_words_array.join(" ")
  end

end

RSpec.describe PigLatin do
  describe "#translate" do
    it "should return an empty string when given an empty string" do
      sentence = ""
      translation = ""
      expect( PigLatin.translate(sentence) ).to eq(translation)
    end
    
    it "should correctly translate a sentence including punctuation, words that start with vowels, and words that start with 'qu'" do
      sentence = "hello eat eat world Hello Apples eat… world?! school quick"
      translation = "ellohay eatway eatway orldway Ellohay Applesway eatway… orldway?! oolschay ickquay"
      expect( PigLatin.translate(sentence) ).to eq(translation)
    end
  end
end