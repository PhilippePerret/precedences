require "test_helper"
require 'osatest'

class PrecedencesTest < Minitest::Test

  def setup
    super
    File.delete(precfile) if File.exist?(precfile)
  end

  def precfile
    @precfile ||= File.join(__dir__,'.precedences')
  end

  def test_choices_with_precedences
    assert_silent { choices_with_precedences([], precfile) }
  end

  def test_choices_with_precedences_save_precedences
    
    choices = [
      {name:"First", value: :first},
      {name:"Second", value: :second},
      {name:"Third", value: :third},
    ]

    choices = choices_with_precedences(choices, precfile)

    assert_equal('First', choices[0][:name])
    assert_equal('Second', choices[1][:name])
    assert_equal('Third', choices[2][:name])

    set_precedence(:second)

    choices = choices_with_precedences(choices, precfile)

    assert_equal('Second', choices[0][:name])
    assert_equal('First', choices[1][:name])
    assert_equal('Third', choices[2][:name])

    set_precedence(:third)

    choices = choices_with_precedences(choices, precfile)

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

  def test_choices_precedences_with_bloc


    refute(File.exist?(precfile))

    tosa = OSATest.new({
      app:'Terminal', 
      delay:0.5, 
      window_bounds:[0,0,1200,600]
    })

    tosa.new_window
    tosa.run("cd '#{__dir__}';ruby ./live.rb")
    action "Je choisis le deuxième"
    tosa << :DOWN
    sleep 0.5
    tosa.fast [:RET]
    # Vérification
    order_must_be(['second'])
    action "Je choisis le troisième"
    tosa << 2.down
    sleep 0.5
    tosa.fast [:RET]
    # Vérification
    order_must_be(['third','second'])
    action "Je choisis le premier"
    tosa << 2.down
    sleep 0.5
    tosa.fast [:RET]
    # Vérification
    order_must_be(['first', 'third','second'])
    action "Je choisis le quatrième"
    tosa << 4.down
    sleep 0.5
    tosa.fast [:RET]
    # Vérification
    order_must_be(['fourth', 'first', 'third','second'])

    tosa.finish
    # TODO Poursuivre des vérifications avec des changements de choices (ajouts et retraits)

  end

  def test_values_must_be_scalaire
    # TODO
  end

end
