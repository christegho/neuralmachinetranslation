export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
export PATH=$PATH:$HiFST/bin/
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/
alias printstrings=printstrings.sta.O2.bin

DIR=/remote/mlsalt-staff/wjb31/MLSALT/MLSALT8/practicals/practical-3

zcat kyoto-dev.en.gz | awk 'NR==15'


printstrings --input=$DIR/hifst/lats.dev/?.fst --range=1:1166 --output=dev.hyps.id
$DIR/scripts/eval.sh dev.hyps.id $DIR/data/wmap.en $DIR/data/dev.en
BLEU = 15.68, 53.1/21.4/10.3/5.2 (BP=1.000, ratio=1.000, hyp_len=24316, ref_len=24309)

printstrings --input=$DIR/hifst/lats.test/?.fst --range=1:1160 --output=test.hyps.id
$DIR/scripts/eval.sh test.hyps.id $DIR/data/wmap.en $DIR/data/test.en
BLEU = 18.06, 54.8/24.1/12.7/7.4 (BP=0.963, ratio=0.963, hyp_len=25753, ref_len=26734)

mkdir words/ ; cd words/
cp -r $DIR/nmt/words/ini .

$DIR/nmt/words/train/


source /home/ech57/tools/scripts/tf_helper_cpu.sh
python /home/fs439/bin/sgnmt/decode.py --config_file ini/nmt.beta0.03_dev.ini
--range 2:3 --output_path=tmp.%s

python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.en -d i2s -t id < tmp.text

$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/nmt_dev ini/nmt.beta0.03_dev.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/nmt_test ini/nmt.beta0.03_test.ini

#TODO
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/nmt_dev ini/nmt.beta0.03_dev.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/nmt_test ini/nmt.beta0.03_test.ini


# dev set
cat `ls -1v output/nmt_dev/*.text` > output/nmt_dev/hyps.ids
# test set
cat `ls -1v output/nmt_test/*.text` > output/nmt_test/hyps.ids
#Scoring is done with the eval.sh script:
# dev set
$DIR/scripts/eval.sh output/nmt_dev/hyps.ids $DIR/data/wmap.en $DIR/data/dev.en
#BLEU = 14.89, 48.6/20.4/10.0/5.3 (BP=0.980, ratio=0.980, hyp_len=23833, ref_len=24309)
# test set
$DIR/scripts/eval.sh output/nmt_test/hyps.ids $DIR/data/wmap.en $DIR/data/test.en
#BLEU = 16.69, 49.9/22.4/11.9/6.9 (BP=0.957, ratio=0.958, hyp_len=25614, ref_len=26734

#To accumulate all the seconds spent in decoding by all the workers:
cat output/nmt_test/logs/*| fgrep 'Stats' |\sed 's,.*=,,' | awk '{acc = acc + $NF}END{print acc}'

#END TODO
mkdir bpe/ ; cd bpe/
cp -r $DIR/nmt/bpe/ini .

#The BPE inventories used in this practical are available in
$DIR/nmt/bpe/mapping/bpe.train.ja
$DIR/nmt/bpe/mapping/bpe.train.en

head -5 $DIR/nmt/bpe/mapping/bpe.train.en

head -1 $DIR/data/train.en | python $DIR/scripts/apply_bpe_with_eow.py -c $DIR/nmt/bpe/mapping/bpe.train.en -s ''

#We  build  ‘wordmaps’  for  the  BPE  symbol inventories:
$DIR/data/wmap.bpe.en, $DIR/data/wmap.bpe.ja

head -1 $DIR/data/train.en | python $DIR/scripts/apply_bpe_with_eow.py -c $DIR/nmt/bpe/mapping/bpe.train.en -s '' | python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.en -d s2i > train.bpe.en

head -1 $DIR/data/train.ja | python $DIR/scripts/apply_bpe_with_eow.py -c $DIR/nmt/bpe/mapping/bpe.train.ja -s '' | python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.ja -d s2i > train.bpe.ja

#All of the BPE files inc$DIR/datacare generated in this way:
dev.bpe.[en,ja], test.bpe.[en,ja], train.bpe.[en,ja], wmap.bpe.[en,ja]

#The effect of the BPE transformation can be seen in the size of the parallel text.  The number of lines is of course unchanged, however the total number of words increases by 7% in English and 4% in Japanese:
wc -lw $DIR/data/train.ids.en $DIR/data/train.bpe.en
#329882 5911486 $DIR/data/train.ids.en
#329882 6332087 $DIR/data/train.bpe.en
wc -lw $DIR/data/train.ids.ja $DIR/data/train.bpe.ja
#329882 6085131 $DIR/data/train.ids.ja
#329882 6309999 $DIR/data/train.bpe.ja

python /home/fs439/bin/sgnmt/decode.py --config_file ini/nmt.beta0.04_dev.ini \
--range 2:3 --output_path=tmp.%s

#TODO

python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.en -d i2s -t id < tmp.text
python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.en -d i2s -t eow < tmp.text

#TODO  Batch Translation of the Dev and Test Sets
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/nmt_dev ini/nmt.beta0.04_dev.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/nmt_test ini/nmt.beta0.04_test.ini

#TODO    BLEU Scores and Computing Time
cat `ls -1v output/nmt_dev/*.text` > output/nmt_dev/hyps.ids
#The eval.sh script maps the BPE strings to words, as described above, prior to computing the BLEU score:
$DIR/scripts/eval.sh output/nmt_dev/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/dev.en
#eow
#BLEU = 14.59, 48.6/20.3/9.8/5.1 (BP=0.977, ratio=0.977, hyp_len=23756, ref_len=24309)
$DIR/scripts/eval.sh output/nmt_test/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/test.en
#eow
#BLEU = 18.41, 51.2/23.9/13.4/8.3 (BP=0.959, ratio=0.960, hyp_len=25652, ref_len=26734)
cat output/nmt_test/logs/* | fgrep 'Stats' | sed 's,.*=,,' |awk '{acc = acc + $NF}END{print acc}'
#108473


