#!/usr/bin/env ruby -U
require 'precedences'

choices = [
  {name:"First"   , value: :first},
  {name:"Second"  , value: :second},
  {name:"Third"   , value: :third},
  {name:"Fourth"  , value: :fourth},
]

precfile = File.join(__dir__, '.precedences')

case ARGV[0]
when "limit-per-page"
  precedencize(choices, precfile) do |q|
    q.per_page 3
  end
when 'test-custom-question'
  precedencize(choices, precfile) do |q|
    q.question "Choisir un item dans la liste"
  end
when "test-custom-help"
  precedencize(choices, precfile) do |q|
    q.show_help true
    q.help "Presser une des flèches"
  end
when "test-default-value"
  choix = precedencize(choices, precfile) do |q|
    q.default 4
  end
  if choix == :fourth
    puts "La valeur Quatre a bien été choisie."
  else
    puts "C'est la valeur #{choix.inspect} qui a été choisie…"
  end
when "test-default-value-by-name"
  choix = precedencize(choices, precfile) do |q|
    q.default "Third"
  end
  if choix == :third
    puts "La valeur Trois a bien été choisie."
  else
    puts "C'est la valeur #{choix.inspect} qui a été choisie…"
  end
when "test-default-value-by-value"
  choix = precedencize(choices, precfile) do |q|
    q.default :second
  end
  if choix == :second
    puts "La valeur Deux a bien été choisie."
  else
    puts "C'est la valeur #{choix.inspect} qui a été choisie…"
  end
when "test-precedence-par-index"
  complex_choices = [
    {name:"La classe Integer" , value: Integer},
    {name:"La classe Hash"    , value: Hash},
    {name:"La classe Array"   , value: Array},
    {name:"La classe String"  , value: String},
  ]
  4.times do
    choix = precedencize(complex_choices, precfile) do |q|
      q.precedences_per_index
    end
  end
else
  # 
  # Le test par défaut pour voir si la liste de précédence 
  # s'actualise bien
  # 
  4.times do
    precedencize(choices, precfile) do |q|
      q.question "Quel item choisir ?"
    end
  end
end
