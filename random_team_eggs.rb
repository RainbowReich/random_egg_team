require "ruby_gs"
require "json"
require "rest-client"

def choose_random_moves(pokemon)
  new_moves = []
  4.times do |i|
    loop do
      move_info_url = pokemon["moves"][rand(pokemon["moves"].length)]["resource_uri"]
      new_moves[i] = JSON.parse(RestClient.get "http://pokeapi.co/#{move_info_url}")["id"]
      break if new_moves[i] < 251 && !new_moves[0...i].include?(new_moves[i])
    end
  end
  new_moves
end

save = RubyGS::SaveFileReader.read ARGV[0]

6.times do |i|
  srand
  rand_species = rand 251
  save.set_team_species i, rand_species
  poke = JSON.parse(RestClient.get "http://pokeapi.co/api/v1/pokemon/#{rand_species}/")
  save.team.name[i] = poke["name"].upcase

  new_moves = choose_random_moves(poke)

  save.team.pokemon[i].move_1 = new_moves[0]
  save.team.pokemon[i].move_2 = new_moves[1]
  save.team.pokemon[i].move_3 = new_moves[2]
  save.team.pokemon[i].move_4 = new_moves[3]
 
  save.team.pokemon[i].exp = 156
  save.team.pokemon[i].level = 5
  save.set_team_egg i if i > 0

end

save.write
`vbam #{ARGV[0]}`
