#!/usr/bin/env ruby -U
require 'precedences'

choices = [
  {name:"First"   , value: :first},
  {name:"Second"  , value: :second},
  {name:"Third"   , value: :third},
  {name:"Fourth"  , value: :fourth},
]

precfile = File.join(__dir__, '.precedences')

4.times do
  choices_with_precedences(choices, precfile) do
    "Quel item choisir ?"
  end
end
