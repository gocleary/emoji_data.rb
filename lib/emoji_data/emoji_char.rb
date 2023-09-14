# frozen_string_literal: true

module EmojiData
  # EmojiChar represents a single Emoji character and its associated metadata.
  #
  # @!attribute name
  #   @return [String] The standardized name used in the Unicode specification
  #     to represent this emoji character.
  #
  # @!attribute unified
  #   @return [String] The primary unified codepoint ID for the emoji character.
  #
  # @!attribute skin_variations
  #   @return [Array<String>] A list of all variant codepoints that may also
  #     represent this emoji.
  #
  # @!attribute short_name
  #   @return [String] The canonical "short name" or keyword used in many
  #     systems to refer to this emoji. Often surrounded by `:colons:` in
  #     systems like GitHub & Campfire.
  #
  # @!attribute short_names
  #   @return [Array<String>] A full list of possible keywords for the emoji.
  #
  # @!attribute text
  #   @return [String] An alternate textual representation of the emoji, for
  #   example a smiley face emoji may be represented with an ASCII alternative.
  #   Most emoji do not have a text alternative. This is typically used when
  #   building an automatic translation from typed emoticons.
  #
  class EmojiChar
    attr_reader :skin_variations

    # skin-tone-1 is the default and does not have a modifier
    SKIN_TONE_MAPPING = {
      2 => '1F3FB',
      3 => '1F3FC',
      4 => '1F3FD',
      5 => '1F3FE',
      6 => '1F3FF'
    }.freeze

    def initialize(emoji_hash)
      # work around inconsistency in emoji.json for now by just setting a blank
      # array for instance value, and let it get overriden in main
      # deserialization loop if variable is present.
      @skin_variations = []

      # trick for declaring instance variables while iterating over a hash
      # http://stackoverflow.com/questions/1615190/
      emoji_hash.each do |k, v|
        instance_variable_set("@#{k}", v)
        eigenclass = class << self; self; end
        eigenclass.class_eval { attr_reader k }
      end
    end

    # Renders an `EmojiChar` to its string glyph representation, suitable for
    # printing to screen.
    #
    # @skin_tone [Integer] :variant_encoding specify whether the variant
    #   encoding selector should be used to hint to rendering devices that
    #   "graphic" representation should be used. By default, we use this for all
    #   Emoji characters that contain a possible variant.
    #
    # @return [String] the emoji character rendered to a UTF-8 string
    def render(skin_tone: nil)
      variant = if skin_tone.nil? || skin_tone == 1
                  unified
                else
                  skin_tone_unicode = SKIN_TONE_MAPPING[skin_tone]
                  skin_variations.dig(skin_tone_unicode, 'unified')
                end

      return if variant.nil?

      EmojiChar.unified_to_char(variant)
    end

    # Returns the unified code of the emoji
    #
    # @skin_tone [Integer] :variant_encoding specify whether we should
    #   return the default unified or a skin variation one.
    #
    # @return String : the unified code
    def unified_code(skin_tone: nil)
      return unified if skin_tone.nil? || skin_tone == 1

      skin_tone_unicode = SKIN_TONE_MAPPING[skin_tone]
      skin_variations.dig(skin_tone_unicode, 'unified')
    end

    # Returns a list of all possible UTF-8 string renderings of an `EmojiChar`.
    #
    # E.g., normal, with variant selectors, etc. This is useful if you want to
    # have all possible values to match against when searching for the emoji in
    # a string representation.
    #
    # @return [Array<String>] all possible UTF-8 string renderings
    def chars
      results = [EmojiChar.unified_to_char(unified)]
      @skin_variations.each do |_key, value|
        results << EmojiChar.unified_to_char(value['unified'])
      end
      @chars ||= results
    end

    # Is the `EmojiChar` represented by a multibyte codepoint in Unicode?
    #
    # @return [Boolean]
    def multibyte?
      @unified.include? '-'
    end

    # Does the `EmojiChar` have an alternate Unicode variant encoding?
    #
    # @return [Boolean]
    def variations?
      !@skin_variations.empty?
    end

    def self.unified_to_char(cps)
      cps.split('-').map { |cp| cp.to_i(16) }.pack('U*')
    end

    def self.char_to_unified(char)
      char.codepoints.to_a.map { |i| i.to_s(16).rjust(4, '0') }.join('-').upcase
    end
  end
end
