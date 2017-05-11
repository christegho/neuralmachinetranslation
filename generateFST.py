file = open('tmp.w2bpe')
state = 1
for line in file:
	line = line.split()
        if len(line) > 2:
         	print 0, state, line[0], line[1]
		state += 1
		for k in range(2, len(line)):
			print (state-1), state, 0, line[k]
			state += 1
        else:
    		print 0, 0, line[0], line[1]
	    
