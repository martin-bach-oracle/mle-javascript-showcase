import { describe, expect, test, beforeAll, afterAll } from "vitest";
import * as t from "../src/typescript/todos";
import oracledb from "oracledb";

// the database connection. Initialised during the call to beforeAll()
// there's no Typescript type for the connection AFAIK
let connection;

// the primary key of the todo item created, updated, and eventually deleted
let id: number;

/**
 * initialise the database connection before starting any tests.
 *
 * Requires adding the connection to GlobalThis for the Typescript
 * code to work with node.js
 *
 * DO NOT HARD CODE credentials in production applications. This
 * is acceptable ONLY in _this_ particular playground/showcase
 * environment
 */
beforeAll(async () => {
	connection = await oracledb.getConnection({
		user: "demouser",
		password: "demouser",
		connectionString: "localhost/freepdb1",
	});
});

describe("todo unit tests", () => {
	/**
	 * Start the test series by creating a new Todo item
	 */
	test("add a new todo item", async () => {
		// use the type definition as per src/typescript/test.ts
		// and make use of Typescript
		const todo: t.TodoItem = {
			name: "enter a todo item via a unit test",
			priority: t.Priority.low,
			created: new Date("2025-06-06T12:00:00.000Z"),
			dueDate: new Date("2025-06-12T14:00:00.000Z"),
			done: false,
		};

		// invoke the PL/SQL call specification to create a new
		// todo item
		const result = await connection.execute(
			`declare
                id number;
            begin
                :id := todos_package.new_todo(:todo);
            end;`,
			{
				id: {
					type: oracledb.NUMBER,
					dir: oracledb.BIND_OUT,
				},
				todo: {
					val: todo,
					dir: oracledb.BIND_IN,
					type: oracledb.DB_TYPE_JSON,
				},
			},
		);

		id = result.outBinds.id;
		expect(id).toBeGreaterThan(0);
	});

	/**
	 * Get details about the previously created todo item
	 */
	test("retrieve the todo item's details", async () => {
		// invoke the PL/SQL call specification to retrieve
		// the previously created todo item
		const result = await connection.execute(
			`select
				todos_package.get_todo(:id) as todoItem`,
			[id],
			{
				outFormat: oracledb.OUT_FORMAT_OBJECT,
			},
		);

		expect(result.rows.length).toBe(1);
	});

	/**
	 * Update the Todo Item
	 */
	test("update the todo item's details", async () => {
		const todoItem: t.TodoItem = {
			name: "update the todo item via a unit test",
			priority: t.Priority.high,
			created: new Date("2025-06-06T12:00:00.000Z"),
			dueDate: new Date("2025-06-12T14:00:00.000Z"),
			done: true,
		};

		const result = await connection.execute(
			`begin
				
				:l_status := todos_package.update_todo(id => :todo_id, todo => :todo_item);
			end;`,
			{
				l_status: {
					dir: oracledb.BIND_OUT,
					type: oracledb.DB_TYPE_BOOLEAN,
				},
				todo_id: {
					dir: oracledb.BIND_IN,
					val: id,
					type: oracledb.NUMBER,
				},
				todo_item: {
					dir: oracledb.BIND_IN,
					val: todoItem,
					type: oracledb.DB_TYPE_JSON,
				},
			},
		);

		expect(result.outBinds.l_status).toBeTruthy();
	});

	/**
	 * Ensure the update worked as expected
	 */
	test("ensure the update worked as expected", async () => {
		// invoke the PL/SQL call specification to retrieve
		// the previously created todo item
		const result = await connection.execute(
			`select
				todos_package.get_todo(:id) as todoItem`,
			[id],
			{
				outFormat: oracledb.OUT_FORMAT_OBJECT,
			},
		);

		const actualTodoItem = result.rows[0].TODOITEM;
		const referenceTodoItem = {
			priority: "high",
			name: "update the todo item via a unit test",
			created: new Date("Fri Jun 06 2025 12:00:00 GMT+0200 (Central European Summer Time)"),
			dueDate: new Date("Thu Jun 12 2025 14:00:00 GMT+0200 (Central European Summer Time)"),
			done: true,
		};

		expect(actualTodoItem).toEqual(referenceTodoItem);
	});

	/**
	 * Delete the todo item
	 */
	test("delete the todo item", async () => {
		const result = await connection.execute(
			`begin
				
				:l_status := todos_package.delete_todo(id => :todo_id);
			end;`,
			{
				l_status: {
					dir: oracledb.BIND_OUT,
					type: oracledb.DB_TYPE_BOOLEAN,
				},
				todo_id: {
					dir: oracledb.BIND_IN,
					val: id,
					type: oracledb.NUMBER,
				},
			},
		);

		expect(result.outBinds.l_status).toBeTruthy();
	});
});

afterAll(async () => {
	await connection.close();
});
