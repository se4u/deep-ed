cmd = torch.CmdLine()
cmd:option('-ent_vecs_filename', 'ent_vecs__ep_54.t7', '')
cmd:text()
opt = cmd:parse(arg or {})

local root_data_dir = '/Users/rastogi/Downloads/deep-ed-data'
local vaefn = root_data_dir .. '/generated/ent_vecs/ent_vecs__vae2a2b.t7'
local origfn = root_data_dir .. '/generated/ent_vecs/' .. opt.ent_vecs_filename -- 93
local outfn = origfn:gsub('.t7', '_mimicvae.t7')
print('Loading ' .. origfn .. ' and ' .. vaefn)
vae = torch.load(vaefn)
V = torch.load(origfn)
nrow = V:size()[1]
ncol = V:size()[2]
total = 0
print('nrow ', nrow)
for rowidx=1,nrow do
   if torch.norm(vae[rowidx]) == 0 then
      V[rowidx] = 0.
      total = total + 1   
   end
end
print('Writing ' .. outfn .. ' total ' .. tostring(total))
torch.save(outfn, V)

