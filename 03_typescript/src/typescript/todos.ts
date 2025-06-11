/**
 * @fileoverview a short Typescript demo demonstrating how to create, edit,
 * drop and update Todo items stored in the database. This file must be
 * transpiled using utils/deploy.sh before it can be used with the database.
 *
 * The code is sufficiently small and compact and doesn't need to be spread
 * out into multiple files.
 */

export enum Priority {
	low = "low",
	medium = "medium",
	high = "high",
}

export interface TodoItem {
	priority: Priority;
	name: string;
	created: Date;
	dueDate: Date;
	done: boolean;
}

/**
 * Creates a new Todo item in the database.
 *
 * @param {TodoItem} todo - The Todo item to be created.
 * @returns {number} The ID of the newly created Todo item.
 * @throws {Error} If the insertion fails for any reason or a generic error occurs
 */
export function newTodo(todo: TodoItem): number {
	if (typeof todo !== "object") {
		throw new Error("you must pass a valid todo item to this function");
	}

	const result = session.execute(
		`insert into todos (
            priority,
            name,
            created,
            due_date,
            done
        ) values (
            :priority,
            :name,
            :created,
            :due_date,
            :done
        )
        returning id into :id`,
		{
			priority: {
				type: oracledb.DB_TYPE_VARCHAR,
				dir: oracledb.BIND_IN,
				val: todo.priority,
			},
			name: {
				type: oracledb.DB_TYPE_VARCHAR,
				dir: oracledb.BIND_IN,
				val: todo.name,
			},
			created: {
				type: oracledb.DB_TYPE_DATE,
				dir: oracledb.BIND_IN,
				val: new Date(todo.created),
			},
			due_date: {
				type: oracledb.DB_TYPE_DATE,
				dir: oracledb.BIND_IN,
				val: new Date(todo.dueDate),
			},
			done: {
				type: oracledb.DB_TYPE_BOOLEAN,
				dir: oracledb.BIND_IN,
				val: todo.done,
			},
			id: {
				type: oracledb.NUMBER,
				dir: oracledb.BIND_OUT,
			},
		},
	);

	if (result.rowsAffected !== 1) {
		throw new Error("Failed to insert a new Todo item for an unknown reason");
	}

	// return the automatically generated ID
	return result.outBinds.id[0];
}

export function getTodo(id: number): TodoItem {
	if (typeof id !== "number") {
		throw new Error("you must pass a valid ID to this function");
	}

	// get the details of a newly created Todo item
	const result = session.execute(
		`select 
			id,
			priority,
			name,
			created,
			due_date,
			done
		from
			todos
		where
			id = :id`,
		[id],
	);

	//
	if (result.rows?.length !== 1) {
		throw new Error(`there is no Todo item with id ${id} in the database`);
	}

	const todoItem: TodoItem = {
		priority: result.rows[0].PRIORITY,
		name: result.rows[0].NAME,
		created: result.rows[0].CREATED,
		dueDate: result.rows[0].DUE_DATE,
		done: result.rows[0].DONE,
	};

	return todoItem;
}

/**
 * Updates an existing Todo item.
 *
 * @param {number} id - the todo item's primary key
 * @param {TodoItem} todo - details about the todo item
 * @throws {Error} If parameters aren't passed properly, the todo item ID does not exist or a generic error occurs
 * @returns {boolean} depending on the successful outcome
 */
export function updateTodo(id: number, todo: TodoItem): boolean {
	if (Number.isNaN(id) || typeof todo !== "object") {
		throw new Error("please pass a valid ID and/or todo item to this function");
	}

	const result = session.execute(
		`update todos set
            priority = :priority,
            name = :name,
            created = :created,
            due_date = :due_date,
            done = :done
         where id = :id`,
		{
			priority: {
				type: oracledb.DB_TYPE_VARCHAR,
				dir: oracledb.BIND_IN,
				val: todo.priority,
			},
			name: {
				type: oracledb.DB_TYPE_VARCHAR,
				dir: oracledb.BIND_IN,
				val: todo.name,
			},
			created: {
				type: oracledb.DB_TYPE_DATE,
				dir: oracledb.BIND_IN,
				val: new Date(todo.created),
			},
			due_date: {
				type: oracledb.DB_TYPE_DATE,
				dir: oracledb.BIND_IN,
				val: new Date(todo.dueDate),
			},
			done: {
				type: oracledb.DB_TYPE_BOOLEAN,
				dir: oracledb.BIND_IN,
				val: todo.done,
			},
			id: {
				type: oracledb.NUMBER,
				dir: oracledb.BIND_IN,
				val: id,
			},
		},
	);

	if (result.rowsAffected !== 1) {
		return false;
	}

	return true;
}

/**
 * Deletes an existing Todo item.
 *
 * @param {number} id - the todo item's primary key
 * @throws {Error} If the todo item ID does not exist or a generic error occurs
 */
export function deleteTodo(id: number) {
	if (Number.isNaN(id)) {
		throw new Error("please provide a valid ID to this function");
	}
	const result = session.execute("delete todo where id = :id", {
		id: {
			dir: oracledb.BIND_IN,
			type: oracledb.DB_TYPE_NUMBER,
			val: id,
		},
	});

	if (result.rowsAffected !== 1) {
		throw new Error(
			`todo item with id ${id} does not exist and cannot be deleted`,
		);
	}
}
