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
      OSATest.new(**{app:'Terminal', delay: 0.3,}).tap { |its| 
        its.new_window 
        its.run "cd '#{__dir__}'"
      }
    end
  end

  def run_test(name)
    tosa.run("ruby ./live.rb #{name}")
  end

  def test_with_block

    run_test "test1"
    tosa.has_in_last_lines(["Choose", "First","Second","Third"])
    tosa.has_not_in_last_lines("Fourth")
    tosa << :RET

  end

end
