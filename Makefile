int:
	mkdir -p int

out:
	mkdir -p out

int/seed: int
	head -c 2 /dev/urandom | hexdump -e '"%u"' | tee int/seed

int/_constraints.lp: setup.lp int/seed
	clingo --verbose=0 --rand-freq=1.0 --seed=`cat int/seed` --quiet=1,2,2 \
		setup.lp \
		| sed -e "s/) /).\n/g" \
		| grep -v SATISFIABLE \
		| grep -v Optimization \
		| grep -v OPTIMUM \
		> int/_constraints.lp || true
	echo "." >> int/_constraints.lp

int/_ftree.lp: family.lp int/_constraints.lp int/seed
	clingo --verbose=0 --rand-freq=0.05 --seed=`cat int/seed` --quiet=1,2,2 \
	  family.lp int/_constraints.lp \
		| sed -e "s/) /).\n/g" \
		| grep -v SATISFIABLE \
		| grep -v Optimization \
		| grep -v OPTIMUM \
		> int/_ftree.lp || true
	echo "." >> int/_ftree.lp

int/_fages.lp: int/_ftree.lp int/seed
	clingo --verbose=0 --rand-freq=0.05 --seed=`cat int/seed` --quiet=1,2,2 \
		int/_ftree.lp age.lp \
		| sed -e "s/) /).\n/g" \
		| grep -v SATISFIABLE \
		| grep -v Optimization \
		| grep -v OPTIMUM \
		> int/_fages.lp || true
	echo "." >> int/_fages.lp

out/viz.pdf: out int/_fages.lp
	cat int/_fages.lp | bin/clgv | dot -Tpdf > out/viz.pdf

.PHONY: clean
clean:
	rm -rf int out

.PHONY: seed
seed: int/seed

.PHONY: viz
viz: out/viz.pdf
