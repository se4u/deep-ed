#!/usr/bin/env bash
ent_vecs_filename=${1-ent_vecs__ep_54.t7}
label=${2-ed_canon}
mycmd=${3-echo}
set -x
echo $HOSTNAME
export CUDNN_PATH=/home/prastog3/tools/cudnn/cudnn-8.0-linux-x64-v5.1/lib64/libcudnn.so.5
export CUDA_VISIBLE_DEVICES=$(free-gpu)
$mycmd th ed/ed.lua -model 'global' -root_data_dir /export/c02/prastog3/deep-ed-data/ -ent_vecs_filename ${ent_vecs_filename} -banner_header $label
