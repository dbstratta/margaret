[
  inputs: [
    "{lib,test}/**/*.{ex,exs}",
    "priv/repo/**/*.{ex,exs}",
    "mix.exs",
    ".formatter.exs",
    ".iex.exs",
    ".credo.exs"
  ],
  import_deps: [:ecto, :plug, :absinthe],
  locals_without_parens: [
    defenum: 3
  ]
]
