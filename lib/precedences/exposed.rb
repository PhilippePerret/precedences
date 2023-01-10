

def choices_with_precedences(choices, filename, &block)
  prec = Clir::Precedence.new(filename)
  Clir::Precedence.current = prec
  return prec.sort(choices, &block)
end

def set_precedence(choix)
  Clir::Precedence.current.set_precedences_ids(choix)
end
