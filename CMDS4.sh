python w2Unk.py >> test.ids.unk.en


for i in 9 8 7 6 5 4 3 2 1 0
do
echo $i >> res.txt
$DIR/scripts/eval.sh test.ids.unk.${i}.en $DIR/data/wmap.en $DIR/data/test.en >>res.txt
done



for i in 05 025 01
do
echo $i >> res.txt
$DIR/scripts/eval.sh test.ids.unk.${i}.en $DIR/data/wmap.en $DIR/data/test.en >>res.txt
done


$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/nmt_dev ini/nmt.beta0.04_dev.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/nmt_test ini/nmt.beta0.04_test.ini

#TODO q3
cat `ls -1v output/nmt_dev/*.text` > output/nmt_dev/hyps.ids
$DIR/scripts/eval.sh output/nmt_dev/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/dev.en eow
cat output/nmt_dev/logs/* | fgrep 'Stats' | sed 's,.*=,,' | awk '{acc = acc + $NF}END{print acc}'
cat `ls -1v output/nmt_test/*.text` > output/nmt_test/hyps.ids
$DIR/scripts/eval.sh output/nmt_test/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/test.en eow
cat output/nmt_test/logs/* | fgrep 'Stats' | sed 's,.*=,,' | awk '{acc = acc + $NF}END{print acc}'

python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.en -d i2s -t eow < output/nmt_test/hyps.ids >> hyps.bpe
python getNeos.py >> neos.txt


# q3b
mkdir hifst/lats.bpe.nounk.dev
for id in `seq 1 1166`; do
echo $id
fstcompose $DIR/hifst/lats.dev/$id.fst w2bpe.en.fst | fstproject --project_output - hifst/lats.bpe.nounk.dev/$id.fst
done

mkdir hifst/lats.bpe.nounk.test
for id in `seq 1 1160`; do
echo $id
fstcompose $DIR/hifst/lats.test/$id.fst w2bpe.en.fst | fstproject --project_output - hifst/lats.bpe.nounk.test/$id.fst
done


$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.bpe.3b.dev ini/fst_dev_3b.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.bpe.3b.test ini/fst_test_3b.ini

#TODO
cat `ls -1v output/lats.bpe.dev/*.text` > output/lats.bpe.dev/hyps.ids
$DIR/scripts/eval.sh output/lats.bpe.dev/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/dev.en
cat output/lats.bpe.dev/logs/* | fgrep 'Stats' | sed 's,.*=,,' | awk '{acc = acc + $NF}END{print acc}'
cat `ls -1v output/lats.bpe.test/*.text` > output/lats.bpe.test/hyps.ids
$DIR/scripts/eval.sh output/lats.bpe.test/hyps.ids $DIR/data/wmap.bpe.en $DIR/data/test.en
cat output/lats.bpe.test/logs/* | fgrep 'Stats' | sed 's,.*=,,' | awk '{acc = acc + $NF}END{print acc}'
