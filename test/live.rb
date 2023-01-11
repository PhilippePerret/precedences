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
when "test1"
  puts "Je dois apprendre à faire le test d'intégration 1"
  precedencize(choices, precfile) do |q|
    q.per_page 3
  end
else
  4.times do
    precedencize(choices, precfile) do |q|
      q.question "Quel item choisir ?"
    end
  end
end
