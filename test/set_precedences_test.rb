=begin

  Ce test s'assure qu'on peut utilise 'set_precedence' tout seul,
  en fournissant le nom du fichier en second argument.

=end
require 'test_helper'

class SetPrecedencesTest < Minitest::Test

  def setup
    super
    File.delete(precfile) if File.exist?(precfile)
  end

  def precfile
    @precfile ||= File.join(__dir__,'.precedences_lonely')
  end


  def test_simple_set_precedence

    refute(File.exist?(precfile))
  
    assert_silent { set_precedence('mon_choix', precfile) }

    assert(File.exist?(precfile))

    actual = File.read(precfile)
    expected = 'mon_choix'
    assert_equal(expected, actual, "Le choix de précédence devrait avoir été enregistré… Le fichier contient #{actual.inspect} alors qu'il devrait contenir #{expected.inspect}.")
  end


  def test_plusieurs_set_precedence

    refute(File.exist?(precfile))
  
    assert_silent { set_precedence('mon choix', precfile) }
    assert(File.exist?(precfile))
    assert_silent { set_precedence('autre choix', precfile) }
    assert_silent { set_precedence('troisième choix', precfile) }
    assert_silent { set_precedence('mon choix', precfile) }

    actual = File.read(precfile)
    expected = "mon choix\ntroisième choix\nautre choix"
    assert_equal(expected, actual, "Le choix de précédence devrait avoir été enregistré… Le fichier contient #{actual.inspect} alors qu'il devrait contenir #{expected.inspect}.")
  end


end 
