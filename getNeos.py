file1 = open('test.en')
file2 = open('train.en')
file3 = open('dev.en')
vocab = []
for line in file1:
	vocab += line.replace('\n', '').split(' ')
for line in file2:
	vocab += line.replace('\n', '').split(' ')
for line in file2:
	vocab += line.replace('\n', '').split(' ')


print len(set(vocab))

file4 = open('hyps.bpe')
j=0
for line in file4:
	words = line.replace('\n', '').split(' ')
	for i in range(len(words)):
		if words[i] not in vocab:
			print words[i]
			j += 1


print j
