# Use the official Rust image as a base
FROM rust:1.81.0-slim-bullseye

# Install PostgreSQL 15 and its development libraries
RUN apt-get update

RUN apt-get install -y postgresql-13 postgresql-server-dev-13 libssl-dev clang

RUN apt-get install -y pkg-config
# Install the pgx CLI tool
RUN cargo install cargo-pgx

# Initialize the pgx environment
RUN cargo pgx init --pg13 /usr/bin/pg_config
RUN rustup component add rustfmt
RUN apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libxml2-utils xsltproc ccache

# Set the working directory
WORKDIR /usr/src/hello_pg_ext
# Copy the project files
COPY hello_pg_ext .

# Build the extension
RUN RUST_BACKTRACE=full cargo pgx package
