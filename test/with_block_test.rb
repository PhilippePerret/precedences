require "test_helper"
require 'osatest'

class BlockPrecedencesTest < Minitest::Test

  def setup
    super
    File.delete(precfile) if File.exist?(precfile)
  end

  def teardown
    super
    tosa.abort.finish
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

  def tosa
    @tosa ||= begin
      OSATest.new(**{app:'Terminal', delay: 0.2,}).tap { |its| 
        its.new_window 
        its.run "cd '#{__dir__}'"
      }
    end
  end

  def run_test(name)
    tosa.run("ruby ./live.rb #{name}")
  end

  def test_with_block_and_customs_things

    # - avec des :value complexe (enregistrement par index) -
    run_test "test-precedence-par-index"
    tosa.delay = 1
    tosa << [:DOWN, :RET]   # => Hash (2)  2
    tosa << [3.down, :RET]  # => String (4) 4,2
    tosa << [2.down, :RET]  # => Integer (1) 4, 2, 1
    tosa << [3.down, :RET]  # => Array   (3) 3,4,2,1
    expected = [3, 4, 2, 1]
    actual = File.read(precfile).split("\n").map(&:to_i)
    assert_equal(expected, actual, "Liste des index devrait être #{expected.inspect} et c'est #{actual.inspect}")
    puts "OK !".vert
    sleep 1
exit
    # - per_page limité -
    run_test "limit-per-page"
    tosa.has_in_last_lines(["Choose", "First","Second","Third"])
    tosa.has_not_in_last_lines("Fourth")
    tosa << :RET

    # - question personnalisée -
    run_test "test-custom-question"
    tosa.has_in_last_lines(["Choisir un item dans la liste", "Fourth"])
    tosa << :RET

    # - aide personnalisée -
    run_test "test-custom-help"
    tosa.has_in_last_lines("Presser une des flèches")
    tosa << :RET

    # - valeur par défaut -
    run_test "test-default-value"
    tosa << :RET
    tosa.has_in_last_lines("La valeur Quatre a bien été choisie.")
  
    # - valeur par défaut par name -
    run_test "test-default-value-by-name"
    tosa << :RET
    tosa.has_in_last_lines("La valeur Trois a bien été choisie.")

    # - valeur par défaut par value -
    run_test "test-default-value-by-value"
    tosa << :RET
    tosa.has_in_last_lines("La valeur Deux a bien été choisie.")

  end

end
