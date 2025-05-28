/**
 *
 * MLE Modules and environments
 *
 */

-- use case: create the MLE module inline with the DDL statement
create mle module common_utils language javascript as
/** 
 * Convert a string delimited by ';' to a JavaScript object and return it
 *
 * only functions exported from a module can be accessed externally
 *
 * @param {string} delimited string (key1=value1;...;keyN=valueN) to convert
 * @returns {object} string converted to a JavaScript object
 */
export function string2JSON(inputString) {
    let myObject = {};
    if ( inputString.length === 0 ) {
        return myObject;
    }

    const kvPairs = inputString.split(";");
    kvPairs.forEach( pair => {
        const tuple = pair.split("=");
        if ( tuple.length === 1 ) {
            tuple[1] = false;
        } else if ( tuple.length != 2 ) {
            throw "parse error: you need to use exactly one " +
            " '=' between key and value and not use '=' in either " + 
            "key or value";
        }
        myObject[tuple[0]] = tuple[1];
    });

    return myObject;
}
/

select
    line,
    text
from
    user_source
where
    name = 'COMMON_UTILS';

select
    object_name,
    object_type
from
    user_objects 
where
    object_name = 'COMMON_UTILS';

-- nothing in USER_MLE_PROCEDURES ... need a call spec first

-- use case: expose the function to SQL and PL/SQL and invoke it
create or replace function string_to_json(p_str varchar2)
return json
as mle module common_utils
signature 'string2JSON';
/

-- alternatively as a package
create or replace package common_utils_package as

    function string_to_json(p_str varchar2)
    return json
        as mle module common_utils
        signature 'string2JSON';
end;
/

select
    string_to_json('a=1;b=2;c=3;d=true');

select
    common_utils_package.string_to_json('a=1;b=2;c=3;d=true');

select
    object_name,
    procedure_name,
    module_name,
    env_name,
    lang_name
from
    user_mle_procedures
where
    object_name in ('STRING_TO_JSON', 'COMMON_UTILS_PACKAGE');

-- use case: create another module importing code from the previous one
create or replace mle module business_logic
language javascript as

// 'helpers' is known as an import name. The import name must be mapped
// to a MLE module. You do this in the next step when creating an MLE
// environment
import { string2JSON } from 'helpers';

export function processOrder(orderData) {

    // remember that string2JSON is defined in the common_utils package
    const orderDataJSON = string2JSON(orderData);

    // insert data using the MLE/JavaScript SQL driver
    const result = session.execute(`
        insert into orders (
            order_id,
            order_date,
            order_mode,
            customer_id,
            order_status, 
            order_total,
            sales_rep_id,
            promotion_id
        )
        select 
            jt.* 
        from
            json_table(:orderDataJSON, '$' columns
                order_id             path '$.order_id',
                order_date timestamp path '$.order_date',
                order_mode           path '$.order_mode',
                customer_id          path '$.customer_id', 
                order_status         path '$.order_status',
                order_total          path '$.order_total', 
                sales_rep_id         path '$.sales_rep_id',
                promotion_id         path '$.promotion_id'
            ) jt`,
        {
            orderDataJSON: {
                val: orderDataJSON,
                type: oracledb.DB_TYPE_JSON
            }
        }
    );

    if ( result.rowsAffected === 1 ) {
        return true;
    } else {
        return false;
    }
}
/

create table orders (
    order_id     number(12) not null,
    order_date   date not null,
    order_mode   varchar2(8),
    customer_id  number(6) not null,
    order_status number(2),
    order_total  number(8,2),
    sales_rep_id number(6),
    promotion_id number(6),
    constraint pk_orders primary key(order_id)
);

create mle env business_logic_env imports (
  'helpers' module common_utils
);

select
    env_name,
    language_options
from
    user_mle_envs;

select
    env_name,
    import_name,
    module_name
from
    user_mle_env_imports;

create or replace function process_order(
        p_order_data varchar2
    ) return boolean
        as mle module business_logic
        env business_logic_env
        signature 'processOrder';
/

declare
    l_success boolean := false;
    l_str     varchar2(256);
begin
    l_str := 'order_id=1;order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1';
    l_success := process_order(l_str);

    -- you should probably think of a better success/failure evaluation
    if l_success then
        dbms_output.put_line('success');
        commit;
    else
        dbms_output.put_line('false');
    end if;
end;
/

select
    order_id,
    order_mode,
    customer_id,
    order_total,
    sales_rep_id
from
    orders 
where
    order_id = 1;