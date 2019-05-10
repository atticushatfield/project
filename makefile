all:  expr miniml evaluation


expr: expr.ml expr.mli 
	ocamlbuild -use-ocamlfind expr.byte


evaluation: evaluation.ml expr
	ocamlbuild -use-ocamlfind evaluation.byte


miniml : miniml.ml
	ocamlbuild -use-ocamlfind miniml.byte


clean: 
	rm -rf _build *.byte