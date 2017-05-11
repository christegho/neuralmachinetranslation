cd Desktop/neuraltranslation/words
alias printstrings=printstrings.sta.O2.bin

DIR=/remote/mlsalt-staff/wjb31/MLSALT/MLSALT8/practicals/practical-3

export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/


$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/fst_dev ini/fst_dev.ini
cat `ls -1v output/fst_dev/*.text` > output/fst_dev/hyps.ids
$DIR/scripts/eval.sh output/fst_dev/hyps.ids $DIR/data/wmap.en $DIR/data/dev.en
#BLEU = 14.76, 51.8/20.8/9.6/4.6 (BP=1.000, ratio=1.039, hyp_len=25255, ref_len=24309)
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/fst_test ini/fst_test.ini
cat `ls -1v output/fst_test/*.text` > output/fst_test/hyps.ids
$DIR/scripts/eval.sh output/fst_test/hyps.ids $DIR/data/wmap.en $DIR/data/test.en
#BLEU = 18.32, 54.3/24.1/12.4/7.2 (BP=0.991, ratio=0.991, hyp_len=26500, ref_len=26734)


#3.3.1 Determinisation and Minimization

for id in `seq 1 1166`; do
fstdeterminize $DIR/hifst/lats.dev/$id.fst | fstminimize > hifst/lats.min.dev/$id.fst 
done

for id in `seq 1 1160`; do
echo $id
fstdeterminize $DIR/hifst/lats.test/$id.fst | fstminimize > hifst/lats.min.test/$id.fst 
done

$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.min.dev ini/fst_dev_3.3.1.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.min.test ini/fst_test_3.3.1.ini

#TODO
cat `ls -1v output/fst_dev/*.text` > output/fst_dev/hyps.ids
$DIR/scripts/eval.sh output/fst_dev/hyps.ids $DIR/data/wmap.en $DIR/data/dev.en

cat `ls -1v output/fst_test/*.text` > output/fst_test/hyps.ids
$DIR/scripts/eval.sh output/fst_test/hyps.ids $DIR/data/wmap.en $DIR/data/test.en

#3.3.2

mkdir hifst/lats.min.er.dev
for id in `seq 1 1166`; do
echo $id
fstrmepsilon hifst/lats.min.dev/$id.fst  > hifst/lats.min.er.dev/$id.fst 
done

mkdir hifst/lats.min.er.test
for id in `seq 1 1160`; do
echo $id
fstrmepsilon hifst/lats.min.test/$id.fst   > hifst/lats.min.er.test/$id.fst 
done

mkdir hifst/lats.log.dev
for id in `seq 1 1166`; do
echo $id
fstmap -map_type=to_log hifst/lats.min.er.dev/$id.fst  > hifst/lats.log.dev/$id.fst 
done

mkdir hifst/lats.log.test
for id in `seq 1 1160`; do
echo $id
fstmap -map_type=to_log hifst/lats.min.er.test/$id.fst  > hifst/lats.log.test/$id.fst 
done

mkdir hifst/lats.stoch.dev
for id in `seq 1 1166`; do
echo $id
fstpush --push_weights=true hifst/lats.log.dev/$id.fst  > hifst/lats.stoch.dev/$id.fst 
done

mkdir hifst/lats.stoch.test
for id in `seq 1 1160`; do
echo $id
fstpush --push_weights=true hifst/lats.log.test/$id.fst  > hifst/lats.stoch.test/$id.fst 
done

mkdir hifst/lats.semstoch.dev
for id in `seq 1 1166`; do
echo $id
fstmap -map_type=to_standard hifst/lats.stoch.dev/$id.fst  > hifst/lats.semstoch.dev/$id.fst 
done

mkdir hifst/lats.semstoch.test
for id in `seq 1 1160`; do
echo $id
fstmap -map_type=to_standard hifst/lats.stoch.test/$id.fst  > hifst/lats.semstoch.test/$id.fst 
done


$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.min.er.dev ini/fst_dev_3.3.1b.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.min.er.test ini/fst_test_3.3.1b.ini

$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.stoch.dev ini/fst_dev_3.3.2.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.stoch.test ini/fst_test_3.3.2.ini

$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.semstoch.dev ini/fst_dev_3.3.2b.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.semstoch.test ini/fst_test_3.3.2b.ini

