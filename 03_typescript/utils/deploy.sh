#!/usr/bin/bash

#
# simulate a CI/CD pipeline by transpiling Typescript to JavaScript
# and loading it into the database.

set -euxo pipefail

# make sure we're in the correct directory or else the relative paths
# won't work an this script fails
[[ $(basename "$(pwd)") != 03_typescript ]] && {
    echo "ERR: make sure you are in 03_typescript before invoking ${0}"
    exit 1
}

# simulate the CI pipeline and create the resulting JavaScript
# file in the dist/ directory
npx biome format --verbose src/typescript --write && \
npx biome lint --verbose src/typescript && \
npx tsc

# Now connect to the database and deploy the transpiled module and database
# schema objects
# connection details are typically stored in a cloud vault. For the sake of this
# showcase/demo it is fine to hard-code values. DO NOT DO THIS YOURSELF
# Note: you must ensure that SQLcl is in your path
sql demouser/demouser@localhost/freepdb1 <<-EOF

whenever sqlerror exit 1

-- create the necessary tables ...
lb update -search-path src/database -changelog-file controller.xml 

-- ... and the typescript code
mle create-module -filename dist/todos.js -module-name todos_module -replace

-- ensure there are no invalid objects
begin
    dbms_utility.compile_schema(user);
end;
/

prompt checking for invalid objects past deployment ...
select
    object_name,
    object_type
from
    user_objects
where
    status != 'VALID';

EOF
