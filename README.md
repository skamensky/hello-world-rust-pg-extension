# Rust PostgreSQL Extension Example

This project demonstrates how to create a PostgreSQL extension using Rust. It serves as a foundational example for building more complex extensions in the future.

## Prerequisites

- Docker
- Bash

## Project Structure

- **Dockerfile**: Builds a Docker image with the necessary environment to compile a Rust-based PostgreSQL extension.
- **test.sh**: A shell script to automate the building, testing, and running of the PostgreSQL extension.


**Run the Test Script**: The `test.sh` script automates the process of:

a. Building the Docker image which compiles the rust extension

b. Creating a temporary container to extract the compiled extension

c. Running a PostgreSQL container, copying the extension into it and running a simple test


To run the test script:

`chmod +x ./test.sh && ./test.sh`

If successful, you should see the following output:

```
Building the Docker image
<Docker build ouptut>
Waiting for PostgreSQL to start...
CREATE EXTENSION
Test passed!
```

