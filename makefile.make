all:  expr helpers miniml

expr: expr.ml expr.mli 
	ocamlbuild -use-ocamlfind expr.byte

evaluation: evaluation.ml expr
	ocamlbuild -use-ocamlfind evaluation.byte

miniml : miniml.ml evaluation expr miniml_parse.mly miniml_lex.mli
	ocamlbuild -use-ocamlfind miniml.byte

clean: 
	rm -rf _build *.byte