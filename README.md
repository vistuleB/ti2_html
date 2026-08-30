# ti2_html

[![Package Version](https://img.shields.io/hexpm/v/ti2_html)](https://hex.pm/packages/ti2_html)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ti2_html/)

```sh
gleam add ti2_html@1
```
```gleam
import ti2_html

pub fn main() {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/ti2_html>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

Local desugarer maintenance:

```sh
gleam run -- --renumber                 # renumber local blame lines
gleam run -- --generate                 # regenerate local_desugarers.gleam
gleam run -- --desugarer-tests          # test every local desugarer
gleam run -- --desugarer-tests <name>   # test one local desugarer
gleam run -- --desugarers               # perform all three operations
gleam run -m local_desugarer_tests       # direct standalone test command
```
