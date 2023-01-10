require "test_helper"
require 'osatest'

class PrecedencesTest < Minitest::Test

  def setup
    super
    File.delete(precfile) if File.exist?(precfile)
  end

  def choices_ini
    @choices_ini ||= [
      {name:"First"   , value: :first   },
      {name:"Second"  , value: :second  },
      {name:"Third"   , value: :third   },
    ]
  end

  def precfile
    @precfile ||= File.join(__dir__,'.precedences')
  end

  def test_choices_with_precedences
    assert_silent { choices_with_precedences(choices_ini.dup, precfile) }
  end

  def test_choices_with_precedences_save_precedences
    
    refute(File.exist?(precfile))

    choices = choices_with_precedences(choices_ini.dup, precfile)

    assert_equal('First', choices[0][:name])
    assert_equal('Second', choices[1][:name])
    assert_equal('Third', choices[2][:name])

    set_precedence(:second)

    choices = choices_with_precedences(choices_ini.dup, precfile)

    assert_equal('Second', choices[0][:name])
    assert_equal('First', choices[1][:name])
    assert_equal('Third', choices[2][:name])

    set_precedence(:third)

    choices = choices_with_precedences(choices_ini.dup, precfile)

    assert_equal('Third', choices[0][:name])
    assert_equal('Second', choices[1][:name])
    assert_equal('First', choices[2][:name])
    
  end

  def order_must_be(order)
    ids = File.read(precfile).split("\n")
    order.each_with_index do |id, idx|
      assert_equal(id, ids[idx])
    end
  end

  def test_succeeds_with_good_choices

    goodchoices = [
      {name:"Avec Symbol" , value: :symbol  },
      {name:"Avec String" , value: 'string' },
      {name:"Integer"     , value: 1        },
      {name:"Float"       , value: 1.0      },
    ]
    assert_silent { choices_with_precedences(goodchoices, precfile) }

  end

###################       TEST DES ERREURS      ###################
  
  def test_with_bad_filepath
    badfile = File.join(__dir__,'mauvais','dossier','pour','precedence')
    err = assert_raises(ArgumentError) { choices_with_precedences(choices_ini.dup, badfile) }
    assert_equal("Precedences file incorrect: its folder doesn't exist.", err.message)
  end

  def test_fails_with_bad_choices

    badchoices = {un: "un", deux: "deux", trois: "trois"}
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Should be a Array.")

    badchoices = [['un', 1], ['deux', 2]]
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Should be a Array of Hash.")

    badchoices = [{name:"Un"}, {name:"Deux"}]
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Every choices should define :name and :value attributes.")

    badchoices = [{name:"Un entier", value: Integer}, {name:"Une table", value: Hash}]
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Attribute :value of choice should only be a String, a Symbol or a Numeric.")

    badchoices = [{name:"Un entier", value: :un}, {name:"Une table", value: 'un'}]
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Bad value: :un and 'un' are the same.")

    badchoices = [{name:"Un entier", value: 1}, {name:"Une table", value: '1'}]
    err = assert_raises(ArgumentError) { choices_with_precedences(badchoices, precfile) }
    assert_equal("Bad choices. Bad value: 1 and '1' are the same.")

  end


end
