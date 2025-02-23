export CUDA_VISIBLE_DEVICES=0

# Use torchacc to train model
cur_path=/tmp/EasyNLP
cd ${cur_path}
if [ ! -f ./tmp/train.tsv ]; then
  wget http://atp-modelzoo-sh.oss-cn-shanghai.aliyuncs.com/release/tutorials/classification/train.tsv
  wget http://atp-modelzoo-sh.oss-cn-shanghai.aliyuncs.com/release/tutorials/classification/dev.tsv
fi
DISTRIBUTED_ARGS="--nproc_per_node 1 --nnodes 1 --node_rank 0 --master_addr localhost --master_port 6009"
xlarun \
  $DISTRIBUTED_ARGS examples/benchmark/main.py \
  --mode train \
  --tables=./tmp/train.tsv,./tmp/dev.tsv \
  --input_schema=label:str:1,sid1:str:1,sid2:str:1,sent1:str:1,sent2:str:1 \
  --first_sequence=sent1 \
  --second_sequence=sent2 \
  --label_name=label \
  --label_enumerate_values=0,1 \
  --checkpoint_dir=./tmp/classification_model/ \
  --learning_rate=3e-5  \
  --epoch_num=2  \
  --random_seed=42 \
  --logging_steps=10 \
  --save_checkpoint_steps=50 \
  --sequence_length=128 \
  --micro_batch_size=200 \
  --app_name=text_classify \
  --data_threads=11 \
  --use_amp \
  --use_torchacc \
  --user_defined_parameters='pretrain_model_name_or_path=bert-small-uncased'
