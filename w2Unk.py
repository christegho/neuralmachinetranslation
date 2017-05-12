file = open('test.ids.en')
file2 = open('train.ids.en')

vocab = []
for line in file2:
	vocab += line.replace('\n', '').split(' ')

word_counter = {}
for word in vocab:
     	if word in word_counter:
		word_counter[word] += 1
	else:
		word_counter[word] = 1

popular_words = sorted(word_counter, key = word_counter.get, reverse = True)

n = int(len(popular_words)*.05)
vocabn = popular_words[:n]
j=0

for line in file:
	words = line.replace('\n', '').split(' ')
	for i in range(len(words)):
		if words[i] not in vocabn:
			words[i] = '0'
			j += 1
	print ' '.join(words)

print j,n
