/** @constant {string} collectionName - The name of the SODA collection. */
const collectionName = 'myCollection';

/**
 * Creates a new, empty, collection. Strictly speaking this step
 * can be omitted but it's left here for the sake of the demo/
 * example.
 * 
 * createCollection() either creates a new collection if none
 * exists by that name, or it opens it should there be one already.
 * @function
 * @returns a collection
 */
export function createTheCollection() {

    soda.createCollection(collectionName);
}
/**
 * Adds sample employee documents to the specified SODA collection.
 * @function
 */
export function addDocumentToCollection() {

    const col = soda.createCollection(collectionName);

    // define a JSON document
    let doc = {
        "empno": 7839,
        "ename": "KING",
        "job": "PRESIDENT",
        "mgr": "",
        "hiredate": "1981-11-17",
        "sal": 5000,
        "comm": 0,
        "deptno": 10
    };

    // insert the document into the collection
    col.insertOne(doc);

    // insert another one
    doc = {
        "empno": 7566,
        "ename": "JONES",
        "job": "MANAGER",
        "mgr": 7839,
        "hiredate": "1981-04-02",
        "sal": 2975,
        "comm": 0,
        "deptno": 20
    };

    col.insertOne(doc);
}

/**
 * Performs a Query-By-Example (QBE) to find and log an employee document by name.
 * @function
 * @throws {Error} If no matching employee is found.
 * @returns an array of employees matching the QBE expression
 */
export function qbeExample() {

    const col = soda.createCollection(collectionName);
    // Array to store found employee documents
    const employees = [];

    try {
        const docCursor = col.find().filter({ "ename": "JONES" }).getCursor();
        // Fetch the first document
        let doc = docCursor.getNext();
        while (doc) {
            const content = doc.getContent();

            employees.push(content);
            // Fetch the next document
            doc = docCursor.getNext();
        }
        if (employees.length === 0) {
            throw new Error('cannot find an employee named "JONES" in the collection');
        }
    } catch (err) {
        throw new Error(`something unexpected went wrong trying to open a document cursor: ${err}`);
    }

    return employees;
}

/**
 * Modifies an existing employee document by increasing the salary.
 * @function
 */
export function modifyDocument() {
    const col = soda.createCollection(collectionName);

    const docCursor = col.find().filter({ "ename": "JONES" }).getCursor();
    // Fetch the first document
    let doc = docCursor.getNext();
    while (doc) {

        const emp = doc.getContent();

        // increase the salary by 10%, rounded to 2 decimal places
        console.log(`Mr. "JONES"'s salary before the raise is ${emp.sal}`);
        emp.sal = Math.round(emp.sal * 1.1 * 100) / 100;
        col.find().key(doc.key).replaceOne(emp);
        console.log(`Mr. "JONES" has been given a raise, his new salary is ${emp.sal}`);

        // Fetch the next document
        doc = docCursor.getNext();
    }
}

/**
 * Deletes a specific employee document from the collection.
 * @function
 * @note This function name is misleading as it deletes a document, not the collection.
 * @throws {Error} If the document could not be deleted.
 */
export function deleteDocument() {
    const col = soda.createCollection(collectionName);

    const result = col.find().filter({ "ename": "JONES" }).remove();
    if ( result.count === 0) {
        throw new Error ("could not delete JONES's employee record");
    }

    console.log('the document has been successfully removed');
}

/**
 * Cleans up by dropping the SODA collection if it exists.
 * @function
 * @throws {Error} If the collection could not be opened or dropped.
 */
export function cleanup() {
    // verify if the collection to be dropped exists in the first place
    const col = soda.openCollection(collectionName);
    if (col === null) {
        return;
    }

    // drop the collection to complete this lab. In other scenarios
    // this might be a dangerous operation since the collection and
    // all its documents are removed permanently
    col.drop();
}