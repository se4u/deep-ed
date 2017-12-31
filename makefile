SHELL := /bin/bash
DP := /export/c02/prastog3/deep-ed-data/
.PHONY:
.SECONDARY:

default:
	echo "Say specific target"

echo_%:
	echo $($*)
# ----------------- #
# Semantic Commands #
# ----------------- #
prepare_features:
	echo 'Install torch and its dependencies.'
	luarocks install tds
	-mkdir $(DP)/generated
	$(MAKE) $(DP)/generated/yago_p_e_m.txt &
	$(MAKE) $(DP)/generated/wikipedia_p_e_m.txt
	$(MAKE) $(DP)/generated/crosswikis_wikipedia_p_e_m.txt
	$(MAKE) $(DP)/generated/ent_wiki_freq.txt
	-mkdir $(DP)/generated/test_train_data/
	th data_gen/gen_test_train_data/gen_all.lua -root_data_dir $(DP)
	th data_gen/gen_wiki_data/gen_ent_wiki_w_repr.lua -root_data_dir $(DP)
	th data_gen/gen_wiki_data/gen_wiki_hyp_train_data.lua -root_data_dir $(DP)
	th words/w_freq/w_freq_gen.lua -root_data_dir $(DP)
	echo "Make training more fast by filtering some of the training data."
	th entities/relatedness/filter_wiki_canonical_words_RLTD.lua -root_data_dir $(DP)
	th entities/relatedness/filter_wiki_hyperlink_contexts_RLTD.lua -root_data_dir $(DP)

# -- Stats:
# --cat aida_testA.csv | wc -l
# --4791
# --cat aida_testA.csv | grep -P 'GT:\t-1' | wc -l
# --43
# --cat aida_testA.csv | grep -P 'GT:\t1,' | wc -l
# --3401
# --cat aida_testB.csv | wc -l
# --4485
# --cat aida_testB.csv | grep -P 'GT:\t-1' | wc -l
# --19
# --cat aida_testB.csv | grep -P 'GT:\t1,' | wc -l
# --3084

# -- Stats:
# --cat wned-ace2004.csv |  wc -l
# --257
# --cat wned-ace2004.csv |  grep -P 'GT:\t-1' | wc -l
# --20
# --cat wned-ace2004.csv | grep -P 'GT:\t1,' | wc -l
# --217
# --cat wned-aquaint.csv |  wc -l
# --727
# --cat wned-aquaint.csv |  grep -P 'GT:\t-1' | wc -l
# --33
# --cat wned-aquaint.csv | grep -P 'GT:\t1,' | wc -l
# --604
# --cat wned-msnbc.csv  | wc -l
# --656
# --cat wned-msnbc.csv |  grep -P 'GT:\t-1' | wc -l
# --22
# --cat wned-msnbc.csv | grep -P 'GT:\t1,' | wc -l
# --496



# All files in the $(DP)/generated/ folder containing the substring "_RLTD" are restricted to this set of entities (should contain 276030 entities).






# --------------- #
# Implementations #
# --------------- #
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
