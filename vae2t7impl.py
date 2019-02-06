''' Go from npz to t7, with the help of name2wid and wid2thid.
Validate the map using relwidset.
'''
from argparse import Namespace
import numpy as np
data_dir = '/export/c02/prastog3/deep-ed-data/'
args = Namespace()
args.vae_npz = data_dir+'../thesis_entitylinking/t2a2b.wiki.emb.npz'
args.vae_txt = data_dir + 'generated/ent_vecs/ent_vecs__vae2a2b.txt'
args.name2wid = data_dir + 'basic_data/wiki_name_id_map.txt'
args.wid2thid = data_dir + 'generated/reltd_ents_wikiid_to_rltdid.txt'

print('Loading', args.vae_npz)
vae = np.load(args.vae_npz)
name2vid = {v:k for k,v in enumerate(vae['names'])}

print('Loading', args.name2wid)
name2wid = {ee[0]:int(ee[1]) for ee in
            (e.strip().split('\t') for e in open(args.name2wid) if len(e.strip()) > 0)}
wid2name = {b:a for a,b in name2wid.items()}

print('Loading', args.wid2thid)
wid2thid = {int(a):int(b) for a,b in (e.strip().split() for e in open(args.wid2thid) if len(e.strip()) > 0)}
thid2wid = {b:a for a,b in wid2thid.items()}
num_rltd_ents = len(wid2thid)

print('Writing', args.vae_txt)
vaemean = vae['mean']
embdim = vaemean.shape[1]
default_emb = ('0. '*embdim).rstrip()+'\n'
with open(args.vae_txt, 'w') as f:
  f.write(default_emb)
  err0, err1, err2 = 0, 0, 0
  for thid in range(2, num_rltd_ents+1):
    if thid not in thid2wid:
      err0 += 1
      f.write(default_emb)
      continue
    
    wid = thid2wid[thid]
    try:
      name = wid2name[wid]
    except:
      err1 += 1
      f.write(default_emb)
      continue
    
    try:
      vid = name2vid[name]
    except:
      err2 += 1
      f.write(default_emb)
      continue
    emb = vaemean[vid]
    f.write(' '.join(f'{e:.6f}' for e in emb))
    f.write('\n')
    pass
  pass
print('num_rltd_ents', num_rltd_ents, 'len(thid2wid)', len(thid2wid))
print('err0', err0, 'err1', err1, 'err2', err2)
