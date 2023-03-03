

def precedencize(choices, filename, &block)
  prec = Clir::Precedence.new(filename)
  Clir::Precedence.current = prec
  return prec.sort(choices, &block)
end

def set_precedence(choix, filename = nil)
  prec =  if filename.nil?
            Clir::Precedence.current  
          else
            Clir::Precedence.new(filename)
          end
  prec.send(:set_precedences_ids, choix)
end
