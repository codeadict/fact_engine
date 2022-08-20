# Fact Engine

Prolog-style, in-memory logic programming interpreter for facts and queries.

## Requirements

- **Elixir 1.12+**

To install Elixir in OSX, it can be done with `brew install elixir`. On other Operating Systems
and Linux distributions, please check [Install Elixir](https://elixir-lang.org/install.html).

Alternatively, if you have Docker installed, the application can run using Docker without having to
install any local packages. See [Running with Docker](#running-with-docker) below.

## Installation

From the project's root directory, run:

```console
mix deps.get
MIX_ENV=prod mix escript.build
```

The above commands will build the `./build_engine` binary to run the application.

## Usage

```console
./fact_engine --input <input_file>
```

## Running with Docker

The [Dockerfile](Dockerfile) included in the project makes it easy to run this program.
First, one needs to build the docker image by running:

```console
docker build -t facts .
```

Now, mount the `test/fixtures/` directory as a volume and run the app inside the `facts`
Docker image.

```console
docker run -v $PWD/test/fixtures:/examples -it facts /fact_engine --input /examples/1/in.txt
```

## Testing

Elixir tests can run from the project's root directory with:

```console
mix test
```

**Tip:** Functional/end-to-end tests can run by adding new directories with
`in.txt` and `out.txt` under [test/fixtures](test/fixtures/) and running:

```console
make build functional_tests
```

## Implementation Notes

Given the time constraints, some shortcuts were taken to complete the functionality. Several
improvements could be applied given more time:

- The parser and evaluation functionality could be tested more in-depth. I have added a few tests
  but more coverage could be added, including Doctests and Property Based Tests.

- Improve the parser; the current implementation is brittle with invalid inputs. It is
  essentially a tokenizer, but there are no parsing rules for the language. Better error
  handling could be added with an indication of the lines that have failed.

- Error handling does not provide the best user experience; it throws errors with Stacktraces
  following the "Let it Crash" philosophy. With more time, I would make it more user-friendly
  errors and redirect them to `stderr` instead of the default `stdout`.

- The storage/inference algorithm is simple; it uses a GenServer with a list because this is
  the easiest construct in the BEAM to maintain the state. The querying
  algorithm uses pattern matching and is not the fastest possible because it uses a lot of recursion.
  Given more time, I would have implemented the storage as an ETS-based Trie or, better a
  Graph (RETE algorithm).

- The system was implemented in a way, that Parsing, Storage/Inference, and Output formatting are
  decoupled from each other. There is room for improvement in decoupling some of the IO logic from
  the command-line interface and having the entire program work as a library.

- There could be better types added to the system and more typing on public functions as well
  as code documentation.
