cd Desktop/neuraltranslation/bpe
alias printstrings=printstrings.sta.O2.bin

DIR=/remote/mlsalt-staff/wjb31/MLSALT/MLSALT8/practicals/practical-3

export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/


#3.4.1    Building the Word to BPE Transducer
#Step 1.Generate Byte Pair Encodings of the English vocabulary. We use the apply bpe with eow.py script for the word mapping (to avoid any UTF-8 problems), and skip the first entry in the wmap.en $DIR/data/wmap.en file (which is the < epsilon > symbol) :
awk 'NR>1{print $1}' $DIR/data/wmap.en | python $DIR/scripts/apply_bpe_with_eow.py -c $DIR/nmt/bpe/mapping/bpe.train.en -s '' > tmp.bpe
#You can inspect the tmp.bpe to see that it contains the BPEs for the words in the wmap.en file.

#Step 2. Generate integer mappings for the BPEs.
cat tmp.bpe | python $DIR/scripts/apply_wmap.py -m $DIR/data/wmap.bpe.en -d s2i > tmp.ids.bpe

#Step 3. Generate an integer mapped version of the mapping of word IDs to BPE sequences:
awk 'NR>1{print $2}' $DIR/data/wmap.en | paste - tmp.ids.bpe > tmp.w2bpe

#For example, line 25230 in tmp.w2bpe contains the entry
awk 'NR==25230' tmp.w2bpe
#25230 5294 18707 480 3783 2042
#to map extraterritoriality (id == 25230) to the sequence  extr ater rit ori ality < /w >.

#Step 4. Build a flower transducer that maps word sequences to sequences of BPEs.  Its input language should be the words in the English vocabulary and its output language should be their byte pair encoding
python generateFST.py >> w2bpe.en.txt
fstcompile w2bpe.en.txt w2bpe.en.fst



# Original word lattice best path
cat $DIR/hifst/lats.test/2.fst | printstrings -m $DIR/data/wmap.en
<s> dogen ( ) was a zen monk in the early kamakura period . </s>
# BPE mapping of the original word lattice best path
cat $DIR/hifst/lats.test/2.fst | printstrings -m $DIR/data/wmap.en | python $DIR/scripts/apply_bpe_with_eow.py -c $DIR/nmt/bpe/mapping/bpe.train.en -s ''
<s> dogen</w> (</w> )</w> was</w> a</w> zen</w> monk</w> in</w> the</w> early</w>
kamakura</w> period</w> .</w> </s>
# Best path of the composition of the word to BPE transducer with the original lattice
fstcompose $DIR/hifst/lats.test/2.fst w2bpe.en.fst | fstproject --project_output | printstrings -m $DIR/data/wmap.bpe.en
<s> dogen</w> (</w> )</w> was</w> a</w> zen</w> monk</w> in</w> the</w> early</w>
kamakura</w> period</w> .</w> </s>


mkdir hifst/lats.bpe.dev
for id in `seq 1 1166`; do
echo $id
fstcompose ./words/hifst/lats.semstoch.dev/$id.fst  > hifst/lats.bpe.dev/$id.fst 
done

mkdir hifst/lats.bpe.test
for id in `seq 1 1160`; do
echo $id
fstcompose ./words/hifst/lats.semstoch.test/$id.fst  > hifst/lats.bpe.test/$id.fst 
done


$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1166 output/lats.bpe.dev ini/fst_dev_3.4.2.ini
$DIR/scripts/sgnmt_on_grid_cpu.sh 40 1160 output/lats.bpe.test ini/fst_test_3.4.2.ini
