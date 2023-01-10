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

end
