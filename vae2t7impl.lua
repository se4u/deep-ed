local infn = '/export/c02/prastog3/deep-ed-data/generated/ent_vecs/ent_vecs__vae2a2b.txt'
local outfn = '/export/c02/prastog3/deep-ed-data/generated/ent_vecs/ent_vecs__vae2a2b.t7'
local rowidx = 0
local num_row = 276031
local num_col = 300
local V =  torch.ones(num_row, num_col):mul(1e-10)
dofile 'utils/utils.lua'
for line in io.lines(infn) do
   rowidx = rowidx + 1
   local parts = split(line, ' ')
   assert(table_len(parts) == num_col)
   for j=1,num_col do
      V[rowidx][j] = tonumber(parts[j])
   end
end
torch.save(outfn, V)

