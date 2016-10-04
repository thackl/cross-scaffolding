PATH := bin:util/bwa:util/samtools/bin:util/bcftools/bin:util/seq-scripts/bin:util/seqtk:$(PATH)

.PHONY: all clean samples

all:
	@echo "cross-mates itself doesn't require building. Use"
	@echo "make dependencies # to auto-install required tools in ./util/"
	@echo "make sample-XXX   # to run samples: yeast"

clean:
	-rm -fr util
	-rm -r samples

dependencies:
	hash bwa || $(MAKE) util/bwa
	hash seqtk || $(MAKE) util/seqtk
	hash samtools || $(MAKE) util/samtools
	hash bcftools || $(MAKE) util/bcftools
	hash vcfutils.pl || $(MAKE) util/bcftools
	hash seq-frag || $(MAKE) util/seq-scripts

# util/minimap:
# 	mkdir -p util
# 	cd util && git clone https://github.com/lh3/minimap
# 	cd util/minimap && make

util/bwa:
	mkdir -p util
	cd util && git clone https://github.com/lh3/bwa.git
	cd util/bwa && make

util/samtools:
	mkdir -p util
	cd util && git clone git://github.com/samtools/samtools.git
	cd util/samtools && make

util/bcftools:
	mkdir -p util
	cd util && git clone git://github.com/samtools/htslib.git
	cd util && git clone git://github.com/samtools/bcftools.git 
	cd util/bcftools && make

util/seq-scripts:
	mkdir -p util
	cd util && git clone https://github.com/thackl/seq-scripts.git

util/seqtk:
	mkdir -p util
	cd util && git clone https://github.com/lh3/seqtk.git;
	cd util/seqtk && make

## yeast sample
YEAST=samples/yeast
S228c=$(YEAST)/S228c.fa
CLIB324=$(YEAST)/CLIB324.fq

# requires curl
# requires sratoolkit fastq-dump https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software

sample-yeast: sample-yeast-get
	cd samples/yeast && ../../bin/cross-mates -t 4 -i 1000,2000,5000,10000 S228c.fa CLIB324.fq

sample-yeast-get: $(YEAST) $(S228c) $(CLIB324)

$(YEAST):
	mkdir -p $(YEAST)

$(S228c):
	curl -# ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF_000146045.2_R64/GCF_000146045.2_R64_genomic.fna.gz | gunzip > $(S228c)

$(CLIB324):
	fastq-dump -A SRR3138752 -Z > $(CLIB324)
