from __future__ import print_function
import random,sys

if len(sys.argv) < 3:
    print("Usage: {name} <num_samples> <sample_width>".format(name=sys.argv[0]))
    sys.exit(0)

num_samples = int(sys.argv[1])
sample_width = int(sys.argv[2])

print("Creating {samples} samples of width {width}...".format(samples=num_samples,
                                                              width=sample_width))

outfile = open('testData_{samples}.txt'.format(samples=num_samples), 'w')

for sample in range(num_samples):
    for width in range(sample_width):
        value = random.randint(100,1000)
        if width == 0:
            outfile.write('{value} '.format(value=value))
        elif width == (sample_width -1):
            outfile.write('{value}\n'.format(value=value))
        else: 
            outfile.write('{value} '.format(value=value))
print("Done.")
