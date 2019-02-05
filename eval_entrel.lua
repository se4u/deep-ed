require 'nn'
dofile 'entities/relatedness/relatedness.lua'
opt.ent_vecs_filename = 'ent_vecs__ep_54.t7'
opt.entities = 'RLTD'
unk_ent_thid = 1
get_thid = function (ent_wikiid)
   rltd_only = true
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
dofile 'entities/pretrained_e2v/e2v.lua'
compute_relatedness_metrics(entity_similarity)
