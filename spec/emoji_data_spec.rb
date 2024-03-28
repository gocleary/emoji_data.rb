# frozen_string_literal: false

require 'spec_helper'

RSpec.describe EmojiData do # rubocop:disable Metrics/BlockLength
  describe '.all' do
    it 'should return an array of all 1903 known emoji chars (variations not included)' do
      EmojiData.all.count.should eq(1903)
    end
    it 'should return all EmojiChar objects' do
      EmojiData.all.all? { |char| char.instance_of?(EmojiData::EmojiChar) }.should be_true
    end
  end

  describe '.all_multibyte' do
    it 'should return an array of all 728 known emoji chars with multibyte encoding' do
      EmojiData.all_multibyte.count.should eq(728)
    end
  end

  describe '.all_with_variations' do
    it 'should return an array of all 323 known emoji chars with skin variations' do
      EmojiData.all_with_variations.count.should eq(323)
    end
  end

  describe '.chars' do
    it 'should return an array of all chars in unicode string format' do
      EmojiData.chars.all? { |char| char.instance_of?(String) }.should be_true
    end

    it 'should by default return one entry per known EmojiChar' do
      EmojiData.chars.count.should eq(EmojiData.all.count)
    end

    context 'include_variants: true' do
      it 'should all know 3778 emojis including variants' do
        expect(EmojiData.chars(include_variants: true).count).to eq(3778)
      end

      it 'should not have any duplicates in list when variants are included' do
        result = EmojiData.chars(include_variants: true)
        expect(result.count).to eq(result.uniq.count)
      end
    end
  end

  describe '.from_unified' do
    it 'should find the proper EmojiChar object' do
      results = EmojiData.from_unified('1F680')
      results.should be_kind_of(EmojiChar)
      results.name.should eq('ROCKET')
    end

    it 'should normalise capitalization for hex values' do
      EmojiData.from_unified('1f680').should_not be_nil
    end

    it 'should find via variant encoding ID format as well' do
      result = EmojiData.from_unified('1F918-1F3FF')
      result.should_not be_nil
      result.name.should eq('SIGN OF THE HORNS')
      result.short_name.should eq('the_horns')
    end
  end

  describe '.find_by_name' do
    it 'returns an array of results, upcasing input if needed' do
      EmojiData.find_by_name('tree').should be_kind_of(Array)
      EmojiData.find_by_name('tree').count.should eq(5)
    end
    it 'returns [] if nothing is found' do
      EmojiData.find_by_name('sdlkfjlskdfj').should_not be_nil
      EmojiData.find_by_name('sdlkfjlskdfj').should be_kind_of(Array)
      EmojiData.find_by_name('sdlkfjlskdfj').count.should eq(0)
    end
  end

  describe '.find_by_short_name' do
    it 'returns an array of results, downcasing input if needed' do
      EmojiData.find_by_short_name('MOON').should be_kind_of(Array)
      EmojiData.find_by_short_name('MOON').count.should eq(14)
    end
    it 'returns [] if nothing is found' do
      EmojiData.find_by_short_name('sdlkfjlskdfj').should_not be_nil
      EmojiData.find_by_short_name('sdlkfjlskdfj').should be_kind_of(Array)
      EmojiData.find_by_short_name('sdlkfjlskdfj').count.should eq(0)
    end
  end

  describe '.from_short_name' do
    it 'returns exact matches on a short name' do
      results = EmojiData.from_short_name('scream')
      results.should be_kind_of(EmojiChar)
      results.name.should eq('FACE SCREAMING IN FEAR')
    end
    it 'handles lowercasing input if required' do
      EmojiData.from_short_name('SCREAM').should eq(EmojiData.from_short_name('scream'))
    end
    it 'works on secondary keywords' do
      primary = EmojiData.from_short_name('hankey')
      EmojiData.from_short_name('poop').should eq(primary)
      EmojiData.from_short_name('shit').should eq(primary)
    end
    it 'returns nil if nothing matches' do
      EmojiData.from_short_name('asdfg').should be_nil
    end
  end

  describe '.char_to_unified' do
    it 'converts normal emoji to unified codepoint' do
      expect(EmojiData.char_to_unified('👾')).to eq('1F47E')
      expect(EmojiData.char_to_unified('🚀')).to eq('1F680')
    end

    it 'converts multibyte emoji to proper codepoint' do
      expect(EmojiData.char_to_unified('🇺🇸')).to eq('1F1FA-1F1F8')
      expect(EmojiData.char_to_unified('🧔‍♂️')).to eq('1F9D4-200D-2642-FE0F')
    end

    it 'converts variant encoded emoji to variant unified codepoint' do
      # man_with_beard:skin-tone-5
      expect(EmojiData.char_to_unified('🧔🏾‍♂️')).to eq('1F9D4-1F3FE-200D-2642-FE0F')
    end
  end

  describe '.unified_to_char' do
    it 'converts normal unified codepoints to unicode strings' do
      expect(EmojiData.unified_to_char('1F47E')).to eq('👾')
      expect(EmojiData.unified_to_char('1F680')).to eq('🚀')
    end

    it 'converts multibyte unified codepoints to unicode strings' do
      expect(EmojiData.unified_to_char('1F1FA-1F1F8')).to eq('🇺🇸')
      expect(EmojiData.unified_to_char('1F9D4-200D-2642-FE0F')).to eq('🧔‍♂️')
    end

    it 'converts variant unified codepoints to unicode strings' do
      expect(EmojiData.unified_to_char('1F9D4-1F3FE-200D-2642-FE0F')).to eq('🧔🏾‍♂️')
    end
  end
end
