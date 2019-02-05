SHELL := /bin/bash
DP := /export/c02/prastog3/deep-ed-data/
DPD := $(DP)/generated/test_train_data
FREE_GPU = $(shell free-gpu)
.PHONY:
.SECONDARY:

default:
	echo "Say specific target"

ps_%:
	ps -p $* -o %cpu,%mem,cmd

qlogin_c02:
	qlogin -l 'gpu=1,hostname=c02,h_rt=48:00:00'

echo_%:
	echo $($*)
# ----------------- #
# Semantic Commands #
# ----------------- #
learn_e2v: $(DP)/generated/ent_vecs/ent_vecs_ep_69.t7
prepare_features: prepare_features_impl

# --------------- #
# Implementations #
# --------------- #
## |& is shorthand for 2>&1
$(DP)/generated/ent_vecs/ent_vecs_ep_69.t7:
	CUDNN_PATH="/home/ws15gkumar/.local/cudnn/lib64/libcudnn.so.5" CUDA_VISIBLE_DEVICES=$(FREE_GPU) th entities/learn_e2v/learn_a.lua -root_data_dir $(DP) |& tee $(DP)/logs/log_train_entity_vecs


prepare_features_impl:
	echo 'Install torch and its dependencies.'
	luarocks install tds
	-mkdir $(DP)/generated
	$(MAKE) $(DP)/generated/yago_p_e_m.txt &
	$(MAKE) $(DP)/generated/wikipedia_p_e_m.txt
	$(MAKE) $(DP)/generated/crosswikis_wikipedia_p_e_m.txt
	$(MAKE) $(DP)/generated/ent_wiki_freq.txt
	echo "This repo gives all the AIDA data that you need. There is no need for separately downloading REUTERS and running the jar file in AIDA-CONLL !!!!"
	-mkdir $(DP)/generated/test_train_data/
	th data_gen/gen_test_train_data/gen_all.lua -root_data_dir $(DP)
	$(MAKE) check_test_train_data
	(th data_gen/gen_wiki_data/gen_wiki_hyp_train_data.lua -root_data_dir $(DP); th entities/relatedness/filter_wiki_hyperlink_contexts_RLTD.lua -root_data_dir $(DP)) &
	th data_gen/gen_wiki_data/gen_ent_wiki_w_repr.lua -root_data_dir $(DP); th words/w_freq/w_freq_gen.lua -root_data_dir $(DP); th entities/relatedness/filter_wiki_canonical_words_RLTD.lua -root_data_dir $(DP)
	echo "Make training more fast by filtering some of the training data."

check_test_train_data:
	[[ 4791 == `cat $(DPD)/aida_testA.csv | wc -l` ]] || echo fail0
	[[ 43 == `grep -P 'GT:\t-1' $(DPD)/aida_testA.csv | wc -l` ]] || echo fail1
	[[ 3401 == `grep -P 'GT:\t1,' $(DPD)/aida_testA.csv | wc -l` ]] || echo fail2
	[[ 4485 == `cat $(DPD)/aida_testB.csv | wc -l` ]] || echo fail3
	[[ 19 == `grep -P 'GT:\t-1' $(DPD)/aida_testB.csv | wc -l` ]] || echo fail4
	[[ 3084 == `grep -P 'GT:\t1,' $(DPD)/aida_testB.csv | wc -l` ]] || echo fail5
	[[ 257 == `cat $(DPD)/wned-ace2004.csv | wc -l` ]] || echo fail6
	[[ 20 == `grep -P 'GT:\t-1' $(DPD)/wned-ace2004.csv | wc -l` ]] || echo fail7
	[[ 217 == `grep -P 'GT:\t1,' $(DPD)/wned-ace2004.csv | wc -l` ]] || echo fail8
	[[ 727 == `cat $(DPD)/wned-aquaint.csv | wc -l` ]] || echo fail9
	[[ 33 == `grep -P 'GT:\t-1' $(DPD)/wned-aquaint.csv | wc -l` ]] || echo fail10
	[[ 604 == `grep -P 'GT:\t1,' $(DPD)/wned-aquaint.csv | wc -l` ]] || echo fail11
	[[ 656 == `cat $(DPD)/wned-msnbc.csv | wc -l` ]] || echo fail12
	[[ 22 == `grep -P 'GT:\t-1' $(DPD)/wned-msnbc.csv | wc -l` ]] || echo fail13
	[[ 496 == `grep -P 'GT:\t1,' $(DPD)/wned-msnbc.csv | wc -l` ]] || echo fail14

check_wiki_hyperlink_contexts_RLTD.csv:
	cut -d '	' -f 1 $(DP)/generated/wiki_hyperlink_contexts_RLTD.csv | uniq | wc -l

$(DP)/generated/ent_wiki_freq.txt:
	th entities/ent_name2id_freq/e_freq_gen.lua -root_data_dir $(DP)

$(DP)/generated/yago_p_e_m.txt:
	th data_gen/gen_p_e_m/gen_p_e_m_from_yago.lua -root_data_dir $(DP)

$(DP)/generated/crosswikis_wikipedia_p_e_m.txt:
	th data_gen/gen_p_e_m/merge_crosswikis_wiki.lua -root_data_dir $(DP)

$(DP)/generated/wikipedia_p_e_m.txt: $(DP)/basic_data
	th data_gen/gen_p_e_m/gen_p_e_m_from_wiki.lua -root_data_dir $(DP)

$(DP)/basic_data:
	echo "I downloaded basic_data.zip from google drive through w3m https://drive.google.com/uc?id=0Bx8d3azIm_ZcbHMtVmRVc1o5TWM&export=download"

$(DP)/pretrained:
	cd $(DP)
	curl -L -O https://polybox.ethz.ch/index.php/s/sH2JSB2c1OSj7yv/download
	mv download pretrained.zip
	unzip pretrained.zip
	mv deep_ed_data pretrained


2mac:
	-mkdir -p ~/Downloads/deep-ed-data/generated/
	rsync -avz clsp:/export/c02/prastog3/deep-ed-data/generated/relatedness*  ~/Downloads/deep-ed-data/generated/
	rsync -avz clsp:/export/c02/prastog3/deep-ed-data/generated/all_candidate_ents_ed_rltd_datasets_RLTD.t7  ~/Downloads/deep-ed-data/generated/
	rsync -avz clsp:/export/c02/prastog3/deep-ed-data/basic_data/relatedness ~/Downloads/deep-ed-data/

# eval entity relatedness
entrel:
	th eval_entrel.lua -root_data_dir /export/c02/prastog3/deep-ed-data/
