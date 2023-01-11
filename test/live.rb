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
else
  4.times do
    precedencize(choices, precfile) do |q|
      q.question "Quel item choisir ?"
    end
  end
end
