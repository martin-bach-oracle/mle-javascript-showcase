# MLE JavaScript Showcase

Oracle Database 23ai introduces [In-Database JavaScript](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/) for Linux x86-64 and aarch64. That’s Linux on Intel and Arm, respectively. Developers with a preference for Typescript can use it alternatively after transpilation to JavaScript. JavaScript support in Oracle Database is known as **Multilingual Engine**, or MLE for short.

This project is intended to be run via GitHub codespaces and showcase MLE/JavaScript features in a simple-to-set up environment.

Examples include:

- Writing custom JavaScript code
- Use of Typescript with MLE
- Integrating JavaScript code with APEX

## Usage

You can use this repository in 2 ways:

- Directly within GitHub Codespaces
- Locally

Both are discussed in turn.

### GitHub Codespaces

The repository contains instructions in `.devcontainer/devcontainer.json` creating a development environment in GitHub Codespaces. It might take a minute or 2 to create, please be patient. As part of the Codespace initialisation a database will be set up including a demo account, `demouser`, in `freepdb1` using docker-compose. Update the compose file to the latest database release as per <https://container-registry.oracle.com/ords/ocr/ba/database/free>.

Since VSCode is the default development environment in Codespaces it is only logical to link [SQLDeveloper Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer) into the IDE. Create a new connection in the SQLDev extension and run the scripts as you like and see fit. Connect as demouser/demouser to freepdb1 on `mle-javascript-showcase-oracle-1`.

### Local deployment

You need either Docker or Podman installed and available on your machine. Clone the repository using the standard commands and create the sample database using `01_setup/database.sh`. This file might need updating in case newer images have been made available in <https://container-registry.oracle.com/ords/ocr/ba/database/free>.

As part of the database initialisation you get a new user account in `freepdb1`, named `demouser`. It will be used for all the demo scripts. Using your favourite tool, ideally SQLDeveloper Extension for VSCode, to connect to the database and run the scripts in a worksheet.

## Example Scripts

All scripts are to be run as `demouser` on `freepdb1`; ideally using VSCode and [SQLDeveloper Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)

You'll find **basic examples** in `02_basic_examples`:

- [Inline JavaScript](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/call-specifications-functions.html) functions and procedures
- Examples how to invoke these
- [MLE Modules](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/using-javascript-modules-mle.html)
- [MLE environments](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/specifying-environments-mle-modules.html)
- Examples how to expose JavaScript to SQL and PL/SQL
- Dynamic JavaScript execution

You can find more advanced examples how to write, test, and transpile **Typescript** to In-Database JavaScript in `03_typescript`.

The final set of examples concerns the **NoSQL-style API** named [SODA](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/soda-collections-in-mle-js.html). Simple Oracle Document Access (SODA) is a set of NoSQL-style APIs that let you create and store collections of documents (in particular JSON) in Oracle Database, retrieve them, and query them, without needing to know Structured Query Language (SQL) or how the documents are stored in the database.