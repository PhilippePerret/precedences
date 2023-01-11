module Clir
class Precedence

###################       CLASSE      ###################
  class << self

    attr_accessor :current

  end #/<< self
###################       INSTANCE      ###################

  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
    filepath_validize_or_raises
    # --- Default values ---
    @question   = "Choose:"
    @show_help  = nil
    @help       = ''
    @per_page   = nil
    @default    = 1
    @precedences_per_index = false
  end

  def sort(choices_ini, &block)

    # 
    # On doit évaluer le bloc ici car certaines valeurs peuvent
    # modifier le comportement de la suite.
    # Par exemple, si @precedences_per_index a été mis à true,
    # on peut permettre n'importe quel type de :value dans les 
    # hash
    if block_given?
      block.call(self)
    end

    # 
    # List of choices must be valid
    # 
    choices_valid_or_raises(choices_ini)

    # 
    # Use a clone rather than original list to leave the initial
    # list of choices alone.
    # 
    choices = choices_ini.dup
  
    #
    # Sort the list of choices
    # 
    choices = sort_items(choices)

    if block_given?
      block.call(self)
      # 
      # Tty-select options
      # 
      options = define_tty_options(choices)
      # 
      # On procède au choix
      # 
      choix = Q.select(question.jaune, choices, **options)
      # 
      # On enregistre ce choix (sauf si null ou :cancel)
      # 
      set_precedence(choix) unless choix.nil? || choix == :cancel
      # 
      # On retourne le choix
      # 
      return choix
    else
      # 
      # Sinon, sans block, on renvoie la liste classée
      # 
      return choices
    end
  end

  # --- Predicate Methods ---

  def precedences_per_index?
    @precedences_per_index === true
  end

  # --- Tty prompt Methods ---

  def question(quest = nil)
    @question = quest unless quest.nil?
    return @question
  end
  def question=(quest) ; question(quest) end

  def per_page(value = nil)
    @per_page = value unless value.nil?
    return @per_page
  end
  def per_page=(value); per_page(value) end

  def show_help(value = nil)
    @show_help = value unless value === nil
    return @show_help
  end
  def show_help=(value) ; show_help(value) end

  def default(value = nil)
    @default = value unless value.nil?
    return @default
  end
  def default=(value) ; default(value) end

  def help(value = nil)
    @help = value unless value.nil?
    return @help
  end
  def help=(value) ; help(value) end

  def precedences_per_index(value = nil)
    if value === false
      @precedences_per_index = false
    else
      @precedences_per_index = true
    end
    return @precedences_per_index
  end
  def precedences_per_index=(value) ; precedences_per_index(value) end

  def add_choice_cancel(where = :down, **options)
    
  end



  private


    ##
    # = main =
    #
    # Main method whose sort items
    # 
    # @api private
    def sort_items(choices)
      return choices unless File.exist?(filepath)
      prec_ids = get_precedences_ids
      if precedences_per_index?
        choices_copy = choices.dup
        choices = prec_ids.map do |id| 
          item = choices_copy[id.to_i - 1]
          choices_copy[id.to_i - 1] = nil
          item
        end
        # On ajoute les choix restants
        choices += choices_copy.compact
      else
        # 
        # Cas normal
        # 
        choices.sort!{|a, b|
          (prec_ids.index(a[:value].to_s)||10000) <=> (prec_ids.index(b[:value].to_s)||10000)
        }
      end
      return choices
    end

    ##
    # Define default tty-options (last parameter of select)
    # 
    def define_tty_options(choices)
      {
        per_page:   self.per_page || choices.count,
        show_help:  self.show_help ? :always : :never,
        echo:       nil,
        help:       self.help,
        default:    get_default_value_index(choices),
      }
    end

    # Save the values order in filepath file
    # 
    # @api private
    def set_precedences_ids(value)
      if precedences_per_index?
        # 
        # Mémorisation des choix par index
        # (:value de n'importe quel type, mais la liste original
        #  ne peut pas être changée)
        # 
        @choices_ini.each_with_index do |choice, idx|
          value = (idx + 1).to_s and break if choice[:value] == value
        end
      else
        # 
        # Mémorisation des choix par valeur
        # (plus fiable, la liste peut être changée)
        # 
        value = value.to_s
      end
      pids = get_precedences_ids
      pids.delete(value)
      pids.unshift(value)
      File.write(filepath, pids.join("\n"))
    end

    # Get the values sorted if filepath exists.
    # 
    # @api private
    def get_precedences_ids
      @get_precedences_ids ||= begin
        File.exist?(filepath) ? File.read(filepath).split("\n") : [] 
      end
    end

    ##
    # Check if given filepath (for saving order of choices) is valid.
    # Raise an argument error otherwise.
    # If it's a folder, set to .precedences file
    # 
    # @api private
    def filepath_validize_or_raises
      File.exist?(File.dirname(filepath)) || raise(ArgumentError.new("Precedences incorrect file: its folder should exist."))
      if File.exist?(filepath) && File.directory?(filepath)
        @filepath = File.join(filepath, '.precedences')
      end
    end

    ##
    # Check if given choices are valid. Raise an ArgumentError otherwise
    # 
    # @api private
    def choices_valid_or_raises(choices)
      # 
      # On en aura besoin
      # 
      @choices_ini = choices.dup.freeze

      choices.is_a?(Array) || raise(ArgumentError.new('Bad choices. Should be an Array.'))
      choices.empty? && raise(ArgumentError.new("Bad choices. Shouldn't be empty." ))
      choices[1].is_a?(Hash) || raise(ArgumentError.new('Bad choices. Should be an Array of Hash(s).'))
      # 
      # To check unicity of values
      # 
      cvalues = {}
      # 
      # Check every choice
      # 
      choices.each do |choice|
        choice.key?(:name) || raise(ArgumentError.new("Bad choices. Every choice should define :name attribute."))
        choice.key?(:value) || raise(ArgumentError.new("Bad choices. Every choice should define :value attribute."))
        case choice[:value]
        when Symbol, String, Numeric, NilClass then
          val = choice[:value].to_s
          if cvalues.key?(val)
            raise ArgumentError.new("Bad choices. Value collision: #{choice[:value].inspect} and #{cvalues[val].inspect} are the same, for precedences.")
          else
            cvalues.merge!(val => choice[:value])
          end
        else
          if precedences_per_index?
            # ok, :value peut avoir n'importe quelle valeur
          else
            raise(ArgumentError.new("Bad choices. Attribute :value of choice should only be a String, a Symbol, a Numeric or NilClass. #{choice[:value]} is a #{choice[:value].class}. Add option q.precedences_per_index in block if init never changes."))
          end
        end
      end
    end

    ##
    # @return index (1-based) of default value if defined (even it's a
    # bit silly with precedences…)
    # 
    def get_default_value_index(choices)
      return default if default.is_a?(Integer) && default > 0
      # 
      # On recherche la valeur dans les choix (:name or :value)
      # 
      choices.each_with_index do |choice, idx|
        the_index = idx + 1
        return the_index if choice[:value] == default
        return the_index if choice[:name].match?(/#{default}/)
      end
      # 
      # Si on n'a rien trouvé, on s'en retourne avec le premier
      # 
      return 1
    end
end #/class Precedence
end #/module Clir
