# encoding: UTF-8

require 'spec_helper'

describe 'Range Splitter' do
  it 'adds a split method to instances of Range' do
    expect(Range.new(0,0)).to respond_to :split
  end

  describe 'an ArgumentError is raised' do
    it 'if the into option is not a positive integer' do
      expect {
        (1..10).split(:into => 0)
      }.to raise_error(ArgumentError, /Cannot split/)

      expect {
        (1..10).split(:into => -5)
      }.to raise_error(ArgumentError, /Cannot split/)

      expect { (1..1).split(:into => 1.1)
      }.to raise_error(ArgumentError, /Cannot split/)

      expect { (1..1).split(:into => "abc")
      }.to raise_error(ArgumentError, /Cannot split/)
    end

    it 'if the endianness option is neither :little nor :big' do
      expect { (1..1).split(:endianness => :little) }.to_not raise_error
      expect { (1..1).split(:endianness => :big)    }.to_not raise_error
      expect { (1..1).split                         }.to_not raise_error

      expect { (1..1).split(:endianness => :foo)
      }.to raise_error(ArgumentError, /endianness/)
    end
  end

  describe 'a TypeError is raised' do
    it 'if the range cannot be split' do
      expect { ((1.1)..(3.3)).split
      }.to raise_error(TypeError, "Can't split through Float")

      expect { ((Time.now)..(Time.now+1000)).split
      }.to raise_error(TypeError, "Can't split through Time")

      expect { ([1]..[2]).split
      }.to raise_error(TypeError, "Can't split through Array")

      expect { (:a..:z).split
      }.to raise_error(TypeError, "Can't split through Symbol")
    end
  end

  context 'When working on Integers' do
    it 'splits a range into an array of ranges' do
      (1..10).each do |i|
        expect((1..10).split(:into => i).size).to eql i
      end
    end

    it 'splits into 2 by default' do
      expect((1..10).split.size).to eql(2)
    end

    it 'returns an array of self if given 1' do
      expect((1..10).split(:into => 1)).to eql [1..10]
      expect((3..8).split(:into => 1)).to eql [3..8]
    end

    it 'places the larger ranges at the beginning' do
      expect((1..9).split).to eql [1..5, 6..9]
      expect((1..11).split).to eql [1..6, 7..11]
      expect((5..8).split(:into => 3)).to eql [5..6, 7..7, 8..8]
    end

    it 'splits as evenly as possible' do
      expect((1..10).split(:into => 4)).to eql [1..3, 4..6, 7..8, 9..10]
      expect((1..13).split(:into => 4)).to eql [1..4, 5..7, 8..10, 11..13]
    end

    it 'supports negative ranges' do
      expect((-10..-1).split).to eql [-10..-6, -5..-1]
      expect((-9..-1).split).to eql [-9..-5, -4..-1]
      expect((-3..7).split(:into => 3)).to eql [-3..0, 1..4, 5..7]
    end

    it 'can return fewer elements than the given argument' do
      expect((1..4).split(:into => 10)).to eql [1..1, 2..2, 3..3, 4..4]
      expect((-3..-2).split(:into => 3)).to eql [-3..-3, -2..-2]
      expect((-1..1).split(:into => 7)).to eql [-1..-1, 0..0, 1..1]
    end

    it 'packs from the end of the array if an optional parameter is given' do
      expect((1..9).split(:endianness => :little)).to eql [1..4, 5..9]
      expect((1..11).split(:endianness => :little)).to eql [1..5, 6..11]
      expect((5..8).split(:into => 3, :endianness => :little)).to eql [5..5, 6..6, 7..8]
    end
  end

  context 'When working with strings' do
    it 'splits a range into an array of ranges' do
      (1..10).each do |i|
        expect(('a'..'j').split(:into => i).size).to eql i
      end
    end

    it 'splits into 2 by default' do
      expect(('a'..'z').split.size).to eql(2)
    end

    it 'returns an array of self if given 1' do
      expect(('a'..'z').split(:into => 1)).to eql ['a'..'z']
    end

    it 'places the larger ranges at the beginning' do
      expect(('1'..'9').split).to eql ['1'..'5', '6'..'9']
      expect(('1'..'11').split).to eql ['1'..'6', '7'..'11']
      expect(('À'..'ß').split(:into => 3)).to eql ['À'..'Ç', 'È'..'Ï', 'Ð'..'ß']
    end

    it 'splits as evenly as possible' do
      expect(('A'..'J').split(:into => 4)).to eql ['A'..'C', 'D'..'F', 'G'..'H', 'I'..'J']
      expect(('A'..'M').split(:into => 4)).to eql ['A'..'D', 'E'..'G', 'H'..'J', 'K'..'M']
    end

    it 'can return fewer elements than the given argument' do
      expect(('a'..'d').split(:into => 10)).to eql ['a'..'a', 'b'..'b', 'c'..'c', 'd'..'d']
    end

    it 'packs from the end of the array if an optional parameter is given' do
      expect(('1'..'9').split(:endianness => :little)).to eql ['1'..'4', '5'..'9']
      expect(('1'..'11').split(:endianness => :little)).to eql ['1'..'5', '6'..'11']
      expect(('5'..'8').split(:into => 3, :endianness => :little)).to eql ['5'..'5', '6'..'6', '7'..'8']
    end

    it 'relies on the character ordinal value' do
      expect(('A'..'z').split).to eql ['A'..']', '^'..'z']
      expect(('1'..'z').split).to eql ['1'..'U', 'V'..'z']
      expect(('ː'..'˟').split(:into => 4)).to eql ['ː'..'ː', 'ˑ'..'ˑ', '˒'..'˘', '˙'..'˟']
    end
  end

end
