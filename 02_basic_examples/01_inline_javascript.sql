/**
 *
 * Inline JavaScript code
 *
 */

-- --------------------------------------------------------------------------------------
-- use case: a one-liner in JavaScript is easier to write than in PL/SQL
create or replace function epoch_to_date(
    "p_epoch" number
) return date
as mle language javascript
{{
    let d = new Date(0);
    d.setUTCSeconds(p_epoch);

    return d;
}};
/

select
    line,
    text
from
    user_source
where
    name = 'EPOCH_TO_DATE';

select
    object_name,
    object_type
from
    user_objects 
where
    object_name = 'EPOCH_TO_DATE';

select
    object_name,
    module_name,
    env_name,
    lang_name
from
    user_mle_procedures
where
    object_name = 'EPOCH_TO_DATE';

select 
    to_char (
        epoch_to_date(
            1728597600
        ),
        'dd.mm.yyyy hh24:mi:ss'
);

-- --------------------------------------------------------------------------------------
-- use case: functional programming techniques to calculate the value
-- of a purchase order provided as a JSON document. Based on the example
-- in JSON Developer's Guide chapter 4
create or replace function order_total(
    "po" json
) return number
as mle language javascript
{{
    // the J in JSON stands for JavaScript
    return po.LineItems
        .map( x => x.Part.UnitPrice * x.Quantity )
        .reduce( 
            (accumulator, currentValue) => accumulator + currentValue, 0
        );
}};
/

declare
    po json;
begin

    po := json('{
      "PONumber"             : 1600,
      "Reference"            : "ABULL-20140421",
      "Requestor"            : "Alexis Bull",
      "User"                 : "ABULL",
      "CostCenter"           : "A50",
      "ShippingInstructions" :
        {"name"    : "Alexis Bull",
         "Address" : {"street"  : "200 Sporting Green",
                      "city"    : "South San Francisco",
                      "state"   : "CA",
                      "zipCode" : 99236,
                      "country" : "United States of America"},
         "Phone"   : [{"type" : "Office", "number" : "909-555-7307"},
                      {"type" : "Mobile", "number" : "415-555-1234"}]},
      "Special Instructions" : null,
      "AllowPartialShipment" : true,
      "LineItems"            :
        [{"ItemNumber" : 1,
          "Part"       : {"Description" : "One Magic Christmas",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 13131092899},
          "Quantity"   : 9.0},
         {"ItemNumber" : 2,
          "Part"       : {"Description" : "Lethal Weapon",
                          "UnitPrice"   : 19.95,
                          "UPCCode"     : 85391628927},
          "Quantity"   : 5.0}]}');
    
    dbms_output.put_line('value of the PO is ' || order_total(po) || ' USD');
end;
/

-- --------------------------------------------------------------------------------------
-- use case: invoke a REST API to retrieve the current IP address
create or replace function invoke_rest_api
return json
as mle language javascript
{{
    await import ("mle-js-fetch");
    const response = await fetch('https://api.ipify.org/?format=json');
    if (response.ok) {
        const data = await response.json();
        return data;
    } else {
        throw new Error(
          `unexpected network error: ${response.status}`
        );
    }
}};
/

select
    json_serialize(
        invoke_rest_api
        pretty
    ) ip_address;

-- --------------------------------------------------------------------------------------
-- use case: pure function (eg one without access to the SQL driver)
create or replace function epoch_to_date(
    "p_epoch" number
) return date
as mle language javascript PURE
{{
    let d = new Date(0);
    d.setUTCSeconds(p_epoch);

    -- this will result in an ORA-04161: ReferenceError: session is not defined
    -- when executed
    const result = session.execute(
        `select 'random thing'`
    )

    return d;
}};
/

select
    epoch_to_date(123456789);

-- fix by removing reference to the SQL driver
create or replace function epoch_to_date(
    "p_epoch" number
) return date
as mle language javascript PURE
{{
    let d = new Date(0);
    d.setUTCSeconds(p_epoch);

    return d;
}};
/

select
    epoch_to_date(123456789);