/**
 *
 * Dynamic JavaScript execution
 *
 */


-- --------------------------------------------------------------------------------------
-- use case: basic call to DBMS_MLE
set serveroutput on;
declare
    l_ctx           dbms_mle.context_handle_t;
    l_source_code   clob;
begin
    -- Create execution context for MLE execution and provide an environment
    l_ctx    := dbms_mle.create_context();
	
    -- using q-quotes to avoid problems with unwanted string termination
    l_source_code := 
q'~

console.log(
    
    session.execute(
        "select 'hello world' as greeting"
    )
    .rows[0]
    .GREETING
);

~';
    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => l_source_code
    );

    dbms_mle.drop_context(l_ctx);
exception
    when others then
        dbms_mle.drop_context(l_ctx);
        raise;
end;
/

-- --------------------------------------------------------------------------------------
-- use case: dynamic import (requires IIFE)
set serveroutput on;
declare
    l_ctx           dbms_mle.context_handle_t;
    l_source_code   clob;
begin
    -- Create execution context for MLE execution and provide an environment
    l_ctx    := dbms_mle.create_context();
	
    -- using q-quotes to avoid problems with unwanted string termination
    l_source_code := 
q'~

(async () => {

    await import ("mle-js-fetch");
    const response = await fetch('https://api.ipify.org/?format=json');
    if (response.ok) {
        const data = await response.json();
        console.log(JSON.stringify(data));
    } else {
        throw new Error(
          `unexpected network error: ${response.status}`
        );
    }

})();

~';
    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => l_source_code
    );

    dbms_mle.drop_context(l_ctx);
exception
    when others then
        dbms_mle.drop_context(l_ctx);
        raise;
end;
/

-- --------------------------------------------------------------------------------------
-- use case: dynamic import requiring an MLE env
declare
    l_ctx           dbms_mle.context_handle_t;
    l_source_code   clob;
begin
    -- Create execution context for MLE execution and provide an environment
    l_ctx    := dbms_mle.create_context(
        environment => 'BUSINESS_LOGIC_ENV'
    );
	
    -- using q-quotes to avoid problems with unwanted string termination
    l_source_code := 
q'~

(async () => {

    await import ("mle-js-fetch");
    const response = await fetch('https://api.ipify.org/?format=json');
    if (response.ok) {
        const data = await response.json();
        console.log(JSON.stringify(data));
    } else {
        throw new Error(
          `unexpected network error: ${response.status}`
        );
    }

})();

~';
    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => l_source_code
    );

    dbms_mle.drop_context(l_ctx);
exception
    when others then
        dbms_mle.drop_context(l_ctx);
        raise;
end;
/