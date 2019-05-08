all:  expr helpers miniml

expr: expr.ml expr.mli 
	ocamlbuild -use-ocamlfind expr.byte

helpers : helpers.ml expr
	ocamlbuild -use-ocamlfind helpers.byte

miniml : miniml.ml miniml_lex.mll miniml_parse.mly
	ocamlbuild -use-ocamlfind miniml.byte

clean: 
	rm -rf _build *.byte