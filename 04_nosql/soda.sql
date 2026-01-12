-- create the module
drop mle module if exists soda_demo_module;

select * from all_objects where upper(object_name) = 'SODA_DEMO_MODULE';

mle create-module -filename soda_demo_module.js -replace -module-name soda_demo_module

-- followed by the environment
create or replace mle env soda_demo_env imports (
    'demo' module soda_demo_module
);

create or replace package soda_demo_pkg
authid current_user     -- so that the soda_app role can work its magic
as
    
    procedure create_collection          as mle module soda_demo_module signature 'createTheCollection';
    procedure add_document_to_collection as mle module soda_demo_module signature 'addDocumentToCollection';
    function  qbe_example return json    as mle module soda_demo_module signature 'qbeExample';
    procedure modify_document            as mle module soda_demo_module signature 'modifyDocument';
    procedure delete_document            as mle module soda_demo_module signature 'deleteDocument';
    procedure cleanup                    as mle module soda_demo_module signature 'cleanup';
end;
/

-- run the examples
set serveroutput on;

-- start fresh
begin
    rollback;
    soda_demo_pkg.cleanup;
end;
/

-- create a new, empty collection
exec soda_demo_pkg.create_collection;

select
    table_name 
from
    user_tables;

select
    *
from
    user_json_collection_tables;

select
    data
from
    "myCollection";

-- populate the collection
exec soda_demo_pkg.add_document_to_collection;

select
    data
from
    "myCollection";

-- search within the collection
select
    soda_demo_pkg.qbe_example;

-- modify a document: give Mr Jones a raise
select
    c.data.ename,
    c.data.sal
from
    "myCollection" c
where
    c.data.ename = 'JONES';

exec soda_demo_pkg.modify_document;

select
    c.data.ename,
    c.data.sal
from
    "myCollection" c
where
    c.data.ename = 'JONES';

-- delete a document
select
    c.data
from
    "myCollection" c
where
    c.data.ename = 'JONES';

exec soda_demo_pkg.delete_document;
commit;

select
    c.data
from
    "myCollection" c
where
    c.data.ename = 'JONES';

-- cleanup
exec soda_demo_pkg.cleanup;
