#lang scribble/doc
@(require scribble/manual
          "utils.ss"
          (for-label scribble/racket))

@title[#:tag "scheme"]{Racket}

@defmodule*[(scribble/racket scribble/scheme)]{The
@racket[scribble/racket] library (or @racketmodname[scribble/scheme]
for backward compatibility) provides utilities for typesetting Racket
code. The @racket[scribble/manual] forms provide a higher-level
interface.}

@defform*[[(define-code id typeset-expr)
           (define-code id typeset-expr uncode-id)
           (define-code id typeset-expr uncode-id d->s-expr)
           (define-code id typeset-expr uncode-id d->s-expr stx-prop-expr)]]{

Binds @racket[id] to a form similar to @racket[racket] or
@racket[racketblock] for typesetting code. The form generated by
@racket[define-code] handles source-location information, escapes via
@racket[unquote], preservation of binding and property information,
and @tech{element transformers}.

The supplied @racket[typeset-expr] expression should produce a
procedure that performs the actual typesetting. This expression is
normally @racket[to-element] or @racket[to-paragraph]. The argument
supplied to @racket[typeset-expr] is normally a syntax object, but
more generally it is the result of applying @racket[d->s-expr].

The optional @racket[uncode-id] specifies the escape from literal code
to be recognized by @racket[id]. The default is @racket[unsyntax].

The optional @racket[d->s-expr] should produce a procedure that
accepts three arguments suitable for @racket[datum->syntax]: a syntax
object or @racket[#f], an arbitrary value, and a vector for a source
location. The result should record as much or as little of the
argument information as needed by @racket[typeset-expr] to typeset the
code. Normally, @racket[d->s-expr] is @racket[datum->syntax].

The @racket[stx-prop-expr] should produce a procedure for recording a
@racket['paren-shape] property when the source expression uses with
@racket[id] has such a property. The default is
@racket[syntax-property].}

@defproc[(to-paragraph [v any/c] [#:qq? qq? any/c #f]) block?]{

Typesets an S-expression that is represented by a syntax object, where
source-location information in the syntax object controls the
generated layout.

Identifiers that have @racket[for-label] bindings are typeset and
hyperlinked based on definitions declared elsewhere (via
@racket[defproc], @racket[defform], etc.). The identifiers
@racketidfont{code:line}, @racketidfont{code:comment},
@racketidfont{code:blank}, @racketidfont{code:hilite}, and
@racketidfont{code:quote} are handled as in @racket[racketblock], as
are identifiers that start with @litchar{_}.

In addition, the given @racket[v] can contain @racket[var-id],
@racket[shaped-parens], @racket[just-context], or
@racket[literal-syntax] structures to be typeset specially (see each
structure type for details), or it can contain @racket[element]
structures that are used directly in the output.

If @racket[qq?] is true, then @racket[v] is rendered ``quasiquote''
style, much like @racket[print] with the @racket[print-as-quasiquote]
parameter set to @racket[#t]. In that case, @racket[for-label]
bindings on identifiers are ignored, since the identifiers are all
quoted in the output. Typically, @racket[qq?] is set to true for
printing result values.}


@defproc[((to-paragraph/prefix [prefix1 any/c] [prefix any/c] [suffix any/c] [#:qq? qq? any/c #f])
          [v any/c]) 
          block?]{

Like @racket[to-paragraph], but @racket[prefix1] is prefixed onto the
first line, @racket[prefix] is prefix to any subsequent line, and
@racket[suffix] is added to the end. The @racket[prefix1],
@racket[prefix], and @racket[suffix] arguments are used as
@tech{content}, except that if @racket[suffix] is a list of elements,
it is added to the end on its own line.}


@defproc[(to-element [v any/c] [#:qq? qq? any/c #f]) element?]{

Like @racket[to-paragraph], except that source-location information is
mostly ignored, since the result is meant to be inlined into a
paragraph.}

@defproc[(to-element/no-color [v any/c] [#:qq? qq? any/c #f]) element?]{

Like @racket[to-element], but @racket[for-syntax] bindings are
ignored, and the generated text is uncolored. This variant is
typically used to typeset results.}


@defstruct[var-id ([sym (or/c symbol? identifier?)])]{

When @racket[to-paragraph] and variants encounter a @racket[var-id]
structure, it is typeset as @racket[sym] in the variable font, like
@racket[racketvarfont]---unless the @racket[var-id] appears under
quote or quasiquote, in which case @racket[sym] is typeset as a symbol.}


@defstruct[shaped-parens ([val any/c]
                          [shape char?])]{

When @racket[to-paragraph] and variants encounter a
@racket[shaped-parens] structure, it is typeset like a syntax object
that has a @racket['paren-shape] property with value @racket[shape].}


@defstruct[just-context ([val any/c]
                         [context syntax?])]{

When @racket[to-paragraph] and variants encounter a
@racket[just-context] structure, it is typeset using the
source-location information of @racket[val] just the lexical context
of @racket[ctx].}


@defstruct[literal-syntax ([stx any/c])]{

When @racket[to-paragraph] and variants encounter a
@racket[literal-syntax] structure, it is typeset as the string form of
@racket[stx]. This can be used to typeset a syntax-object value in the
way that the default printer would represent the value.}


@defproc[(element-id-transformer? [v any/c]) boolean?]{

Provided @racket[for-syntax]; returns @racket[#t] if @racket[v] is an
@tech{element transformer} created by
@racket[make-element-id-transformer], @racket[#f] otherwise.}


@defproc[(make-element-id-transformer [proc (syntax? . -> . syntax?)])
         element-id-transformer?]{

Provided @racket[for-syntax]; creates an @deftech{element
transformer}.  When an identifier has a transformer binding to an
@tech{element transformer}, then forms generated by
@racket[define-code] (including @racket[racket] and
@racket[racketblock]) typeset the identifier by applying the
@racket[proc] to the identifier. The result must be an expression
whose value, typically an @racket[element], is passed on to functions
like @racket[to-paragraph] .}

@defproc[(variable-id? [v any/c]) boolean?]{

Provided @racket[for-syntax]; returns @racket[#t] if @racket[v] is an
@tech{element transformer} created by @racket[make-variable-id],
@racket[#f] otherwise.}


@defproc[(make-variable-id [sym (or/c symbol? identifier?)])
         variable-id?]{

Provided @racket[for-syntax]; like @racket[make-element-id-transformer] for
a transformer that produces @racket[sym] typeset as a variable (like
@racket[racketvarfont])---unless it appears under quote or quasiquote,
in which case @racket[sym] is typeset as a symbol.}

@deftogether[(
@defthing[output-color style?]
@defthing[input-color style?]
@defthing[input-background-color style?]
@defthing[no-color style?]
@defthing[reader-color style?]
@defthing[result-color style?]
@defthing[keyword-color style?]
@defthing[comment-color style?]
@defthing[paren-color style?]
@defthing[meta-color style?]
@defthing[value-color style?]
@defthing[symbol-color style?]
@defthing[variable-color style?]
@defthing[opt-color style?]
@defthing[error-color style?]
@defthing[syntax-link-color style?]
@defthing[value-link-color style?]
@defthing[module-color style?]
@defthing[module-link-color style?]
@defthing[block-color style?]
@defthing[highlighted-color style?]
)]{

Styles that are used for coloring Racket programs, results, and I/O.}
