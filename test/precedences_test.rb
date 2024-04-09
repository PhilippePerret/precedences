require "test_helper"

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

  def test_precedencize
    assert_silent { precedencize(choices_ini.dup, precfile) }
  end

  def test_precedencize_save_precedences
    
    refute(File.exist?(precfile))

    choices = precedencize(choices_ini.dup, precfile)

    assert_equal('First',   choices[0][:name])
    assert_equal('Second',  choices[1][:name])
    assert_equal('Third',   choices[2][:name])

    set_precedence(:second)

    choices = precedencize(choices_ini.dup, precfile)

    assert_equal('Second', choices[0][:name])
    assert_equal('First', choices[1][:name])
    assert_equal('Third', choices[2][:name])

    set_precedence(:third)

    choices = precedencize(choices_ini.dup, precfile)

    assert_equal('Third', choices[0][:name])
    assert_equal('Second', choices[1][:name])
    assert_equal('First', choices[2][:name])
    
  end

  def test_precedencize_with_other_key

    refute(File.exist?(precfile))

    h = {first: "un", second: "deux", third: "trois"}
    choices = choices_ini.map do |choix|
      choix.merge(pkey: h[choix[:value]])
    end

    IO.write(precfile, "deux\ntrois\nun\n")

    prec = Clir::Precedence.new(precfile)
    prec.per_other_key(:pkey)

    sorted_items = prec.send(:sort_items, choices)

    assert_equal('Second',  sorted_items[0][:name])
    assert_equal('Third',   sorted_items[1][:name])
    assert_equal('First',   sorted_items[2][:name])

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
    assert_silent { precedencize(goodchoices, precfile) }

  end

  def test_precedencize_does_change_list_of_choices
    filepath = File.join(mkdir(File.join(__dir__, 'essais')),'.precedences')
    init_choices = [{name:"Premier", value:'un'}, {name:'Deuxième', value:'deux'}]
    duped_choices = init_choices.dup.freeze
    File.write(filepath, "deux")
    new_choices = precedencize(init_choices, filepath)
    assert_equal(duped_choices, init_choices, "Choices list shouldn't have been changed.")
    refute_equal(duped_choices, new_choices, "CHoices list returend shouldn't be the same.")
    expected = [{name:'Deuxième', value:'deux'}, {name:"Premier", value:'un'}]
    assert_equal(expected, new_choices, "Choices list returned shouldn be sorted.")
  end

  def test_choices_can_have_ignored_values
    # Ce test permet de voir si aucun problème n'est produit 
    # lorsque la liste des précédences enregistrés contient des items
    # qui n'existent plus dans la liste.
    # @note
    #   Au départ, on supprimait ces items superflus, mais maintenant
    #   on les conserve car ils peuvent réapparaitre plus tard, lorsque
    #   l'on travaille avec des listes de choix filtrés.
    filepath = File.join(mkdir(File.join(__dir__, 'essais')),'.precedences')
    File.write(filepath, "quinze\nsecond\ndeux")
    assert_silent { precedencize(choices_ini, filepath) }
    set_precedence('third')
    ids = File.read(filepath).split("\n")
    expected = ['third','quinze','second', 'deux']
    assert_equal(expected, ids, "Precedences ids should be #{expected.inspect}. They are #{ids.inspect}.")
  end

  def test_filename_of_filepath
    [
      [__dir__, '.precedences'],
      ['.precedences', '.precedences'],
      ['.prec', '.prec'],
      ['sansext', 'sansext.precedences'],
    ].each do |filepath, expected|
      pr = Clir::Precedence.new(filepath)
      actual = File.basename(pr.filepath)
      assert_equal(expected, actual, "Precedence file name should be '#{expected}'. It is '#{actual}'")
    end
  end

  # Test de l’ajout d’un menu non précédentisé, à l’aide de la
  # méthode DSL #add
  def test_add_choice_not_precedencized
    filepath = File.join(mkdir(File.join(__dir__, 'essais')),'.precadd')
    pr = Clir::Precedence.new(filepath)
    assert_respond_to(pr, :add)    
    assert_respond_to(pr, :add_choice)
    res = pr.send(:prepare_choices, [])
    assert_equal([], res, "Choices should be empty.")
    pr.add("a item", :item)
    res = pr.send(:prepare_choices, [])
    assert_equal([{name: "a item", value: :item}], res)
    # Doit ajouter à la fin par défaut
    pr = Clir::Precedence.new(filepath)
    pr.add_choice("A item", :true)
    res = pr.send(:prepare_choices, [{name:"avant", value: :avant}])
    assert_equal([{name:"avant", value: :avant},{name: "A item", value: :true}], res)
    # Doit ajouter au début si param :at_top
    pr = Clir::Precedence.new(filepath)
    pr.add_choice("A item", :true, **{at_top: true})
    res = pr.send(:prepare_choices, [{name:"avant", value: :avant}])
    assert_equal([{name: "A item", value: :true},{name:"avant", value: :avant}], res)
  end

###################       TEST DES ERREURS      ###################
  
  def test_with_bad_filepath
    badfile = File.join(__dir__,'mauvais','dossier','pour','precedence')
    err = assert_raises(ArgumentError) { precedencize(choices_ini, badfile) }
    assert_equal("Precedences incorrect file: its folder should exist.", err.message)
  end

  def test_with_a_folder
    filepath = mkdir(File.join(__dir__, 'essais'))
    sfile = File.join(filepath, '.precedences')
    File.delete(sfile) if File.exist?(sfile)
    precedencize(choices_ini, filepath)
    set_precedence("un")
    assert(File.exist?(sfile), "File ./test/essais/.precedences should have been created.")
  end

  def test_fails_with_bad_choices

    badchoices = {un: "un", deux: "deux", trois: "trois"}
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Should be an Array.", err.message)

    badchoices = []
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Shouldn't be empty.", err.message)

    badchoices = [['un', 1], ['deux', 2]]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Should be an Array of Hash(s).", err.message)

    badchoices = [{value:'true'}, {name:"Deux", value:'false'}]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Every choice should define :name attribute.", err.message)

    badchoices = [{name:"Un", value:'true'}, {name:"Deux"}]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Every choice should define :value attribute.", err.message)

    badchoices = [{name:"Un entier", value: Integer}, {name:"Une table", value: Hash}]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Attribute :value of choice should only be a String, a Symbol, a Numeric or NilClass. Integer is a Class. Add option q.precedences_per_index in block if init never changes.", err.message)

    badchoices = [{name:"Un entier", value: :un}, {name:"Une table", value: 'un'}]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Value collision: \"un\" and :un are the same, for precedences.", err.message)

    badchoices = [{name:"Un entier", value: 1}, {name:"Une table", value: '1'}]
    err = assert_raises(ArgumentError) { precedencize(badchoices, precfile) }
    assert_equal("Bad choices. Value collision: \"1\" and 1 are the same, for precedences.", err.message)

  end


end
