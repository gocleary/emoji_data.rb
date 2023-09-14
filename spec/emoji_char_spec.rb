# frozen_string_literal: false

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe EmojiChar do
  describe '.new' do
    before(:all) do
      poop_json = '{"name":"PILE OF POO","unified":"1F4A9","variations":[],"docomo":"","au":"E4F5","softbank":"E05A","google":"FE4F4","image":"1f4a9.png","sheet_x":11,"sheet_y":19,"short_name":"hankey","short_names":["hankey","poop","shit"],"text":null}'
      @poop = EmojiChar.new(JSON.parse(poop_json))
    end
    it 'should create instance getters for all key-values in emoji.json, with blanks as nil' do
      @poop.name.should eq('PILE OF POO')
      @poop.unified.should eq('1F4A9')
      @poop.variations.should eq([])
      @poop.docomo.should eq('')
      @poop.au.should eq('E4F5')
      @poop.softbank.should eq('E05A')
      @poop.google.should eq('FE4F4')
      @poop.image.should eq('1f4a9.png')
      @poop.sheet_x.should eq(11)
      @poop.sheet_y.should eq(19)
      @poop.short_name.should eq('hankey')
      @poop.short_names.should eq(%w[hankey poop shit])
      @poop.text.should eq(nil)
    end
  end

  context 'instance methods' do
    let!(:space_invader) { EmojiChar.new({ short_name: 'space_invader', 'unified' => '1F47E' }) }
    let!(:us_flag) { EmojiChar.new({ short_name: 'us', 'unified' => '1F1FA-1F1F8' }) }
    let!(:the_horns) { EmojiChar.new({ short_name: 'the_horns', 'unified' => '1F918', 'skin_variations' => the_horns_skin_variations }) }

    let!(:the_horns_skin_variations) do
      {
        '1F3FB' => { 'unified' => '1F918-1F3FB' },
        '1F3FC' => { 'unified' => '1F918-1F3FC' },
        '1F3FD' => { 'unified' => '1F918-1F3FD' },
        '1F3FE' => { 'unified' => '1F918-1F3FE' },
        '1F3FF' => { 'unified' => '1F918-1F3FF' },
      }
    end

    describe '#render' do
      it 'should render as the emoji string' do
        expect(space_invader.render).to eq('👾')
      end

      it 'should render as happy shiny unicode for multibyte chars too' do
        expect(us_flag.render).to eq('🇺🇸')
      end

      context 'with skin variations' do
        it 'renders default if skin_tone is not present' do
          expect(the_horns.render).to eq('🤘')
        end

        it 'renders default if skin_tone is 1' do
          expect(the_horns.render(skin_tone: 1)).to eq('🤘')
        end

        it 'renders the corresponding emoji based on skin tone' do
          expect(the_horns.render(skin_tone: 2)).to eq('🤘🏻')
          expect(the_horns.render(skin_tone: 3)).to eq('🤘🏼')
          expect(the_horns.render(skin_tone: 4)).to eq('🤘🏽')
          expect(the_horns.render(skin_tone: 5)).to eq('🤘🏾')
          expect(the_horns.render(skin_tone: 6)).to eq('🤘🏿')
        end

        it 'returns nil if skin tone is not a number from 1-6' do
          expect(the_horns.render(skin_tone: 0)).to be_nil
          expect(the_horns.render(skin_tone: 'hello')).to be_nil
        end
      end
    end

    describe '#unified_code' do
      it 'returns unified code' do
        expect(space_invader.unified_code).to eq('1F47E')
      end

      it 'returns correctly for multibyte emojis' do
        expect(us_flag.unified_code).to eq('1F1FA-1F1F8')
      end

      context 'with skin variations' do
        it 'returns default unified if skin_tone is not present' do
          expect(the_horns.unified_code).to eq('1F918')
        end

        it 'returns default unified if skin_tone is 1' do
          expect(the_horns.unified_code(skin_tone: 1)).to eq('1F918')
        end

        it 'returns the corresponding emoji based on skin tone' do
          expect(the_horns.unified_code(skin_tone: 2)).to eq('1F918-1F3FB')
          expect(the_horns.unified_code(skin_tone: 3)).to eq('1F918-1F3FC')
          expect(the_horns.unified_code(skin_tone: 4)).to eq('1F918-1F3FD')
          expect(the_horns.unified_code(skin_tone: 5)).to eq('1F918-1F3FE')
          expect(the_horns.unified_code(skin_tone: 6)).to eq('1F918-1F3FF')
        end

        it 'returns nil if skin tone is not a number from 1-6' do
          expect(the_horns.unified_code(skin_tone: 0)).to be_nil
          expect(the_horns.unified_code(skin_tone: 'hello')).to be_nil
        end
      end
    end

    describe '#chars' do
      it 'returns an array of all possible string render variations' do
        expect(space_invader.chars).to match_array(['👾'])
        expect(us_flag.chars).to match_array(['🇺🇸'])
        expect(the_horns.chars).to match_array(['🤘', '🤘🏻', '🤘🏼', '🤘🏽', '🤘🏾', '🤘🏿'])
      end
    end

    describe '#multibyte?' do
      it 'indicates when a character is multibye based on the unified ID' do
        expect(space_invader.multibyte?).to be(false)
        expect(us_flag.multibyte?).to be(true)
      end
    end

    describe '#variations?' do
      it 'indicates when a character has an alternate variant encoding' do
        expect(space_invader.variations?).to be(false)
        expect(the_horns.variations?).to be(true)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
