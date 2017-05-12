file = open('tmp.w2bpe')
state = 1
for line in file:
	line = line.split()
        if len(line) > 2:
         	print 0, state, line[0], line[1]
		state += 1
		for k in range(2, len(line)-1):
			print (state-1), state, 0, line[k]
			state += 1
		print (state-1), 0, 0, line[len(line)-1]
        else:
    		print 0, 0, line[0], line[1]
	    
