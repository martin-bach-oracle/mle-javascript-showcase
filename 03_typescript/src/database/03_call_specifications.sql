-- liquibase formatted sql
-- changeset martin-bach-oracle:3 endDelimiter:/ runAlways:true

create or replace package todos_package as

    function new_todo(todo json) return number
        as mle module todos_module signature 'newTodo';
    
    function get_todo(id number) return JSON
        as mle module todos_module signature 'getTodo';
    
    function update_todo(id number, todo json) return boolean
        as mle module todos_module signature 'updateTodo';
    
    function delete_todo(id number) return boolean
        as mle module todos_module signature 'deleteTodo';
end todos_package;
/
