require 'nn'
cmd = torch.CmdLine()
cmd:option('-root_data_dir',
           '/Users/rastogi/Downloads/deep-ed-data/',
           'Root path of the data, $DATA_PATH.')
cmd:option('-ent_vecs_filename', 'ent_vecs__ep_54.t7',
           'ent_vecs__vae2a2b.t7 ent_vecs__ep_93.t7')
cmd:option('-print_thid_wikiid', '0', 'Pass 1 to print thid and corresponding wikiid')
cmd:option('-write_w2r', '0', 'Pass 1 to write reltd_ents_wikiid_to_rltdid.txt')
cmd:text()
opt = cmd:parse(arg or {})
dofile 'entities/relatedness/relatedness.lua'
opt.entities = 'RLTD'
unk_ent_thid = 1
rltd_only = true
get_thid = function (ent_wikiid)
  if rltd_only then
    ent_thid = rewtr.reltd_ents_wikiid_to_rltdid[ent_wikiid]
  else
    ent_thid = e_id_name.ent_wikiid2thid[ent_wikiid]
  end
  if (not ent_wikiid) or (not ent_thid) then
    return unk_ent_thid
  end
  return ent_thid
end
print_thid_wikiid = opt.print_thid_wikiid

if opt.write_w2r == '1' then
   w2r = opt.root_data_dir .. 'generated/reltd_ents_wikiid_to_rltdid.txt'
   print('Writing ' .. w2r)
   w2r = io.open(w2r ,'w')
   for a,b in pairs(rewtr.reltd_ents_wikiid_to_rltdid) do
      w2r:write(tostring(a) .. ' ' .. tostring(b) .. '\n')
   end
   w2r:close()
end

-- The following two guard conditions are enough !!
-- tmp = tds.Hash()
-- for a,b in pairs(rewtr.reltd_ents_wikiid_to_rltdid) do
-- tmp[a] = b
-- end
dofile 'entities/pretrained_e2v/e2v.lua'
-- for a,b in pairs(rewtr.reltd_ents_wikiid_to_rltdid) do
-- assert (tmp[a] == b)
-- end

compute_relatedness_metrics(entity_similarity)
