require "test_helper"
require 'osatest'

class BlockPrecedencesTest < Minitest::Test

  def setup
    super
    File.delete(precfile) if File.exist?(precfile)
  end

  def teardown
    super
    # tosa.abort.finish
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
