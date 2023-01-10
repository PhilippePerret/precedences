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
  end

  def sort(choices, &block)
  
    if File.exist?(filepath)
      prec_ids = get_precedences_ids
      choices.sort!{|a, b|
        (prec_ids.index(a[:value].to_s)||10000) <=> (prec_ids.index(b[:value].to_s)||10000)
      }
    end

    if block_given?
      params = block.call
      question, options = 
        if params.is_a?(String)
          [params, nil]
        else
          params
        end
      options ||= {}
      options.merge!({per_page: choices.count, echo:'', show_help:false})
      options.key?(:help) || options.merge!(help: '')
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

  def set_precedences_ids(value)
    value = value.to_s
    pids = get_precedences_ids
    pids.delete(value)
    pids.unshift(value)
    File.write(filepath, pids.join("\n"))
  end

  def get_precedences_ids
    @get_precedences_ids ||= begin
      File.exist?(filepath) ? File.read(filepath).split("\n") : [] 
    end
  end

end #/class Precedence
end #/module Clir
