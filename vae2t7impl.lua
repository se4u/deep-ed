require 'nn'
cmd = torch.CmdLine()
cmd:option('-outfn', 'ent_vecs__vae2a2b.t7')
cmd:option('-random', '0')
cmd:text()
opt = cmd:parse(arg or {})
outfn = '/export/c02/prastog3/deep-ed-data/generated/ent_vecs/' .. opt.outfn
num_row = 276031
num_col = 300
V =  torch.ones(num_row, num_col):mul(1e-10)
if opt.random == '1' then
   print('Starting Random Initialization')
   for rowidx=1,num_row do
      for j=1,num_col do
         -- 0.14 = sqrt(6/300)
         V[rowidx][j] = 0.1428 * torch.uniform()
      end
   end
   print('Done')
else
   local infn = outfn:gsub('.t7', '.txt')
   dofile 'utils/utils.lua'
   local rowidx = 0
   for line in io.lines(infn) do
      rowidx = rowidx + 1
      local parts = split(line, ' ')
      assert(table_len(parts) == num_col)
      for j=1,num_col do
         V[rowidx][j] = tonumber(parts[j])
      end
   end
end
torch.save(outfn, V)
