-- liquibase formatted sql
-- changeset martin-bach-oracle:1

create table todos (
    id number generated always as identity
    constraint pk_todos primary key,
    priority varchar2(10) not null,
    constraint c_todos_priority check (priority in ('low', 'medium', 'high')),
    name varchar2(100),
    created date default sysdate not null,
    due_date date,
    done boolean default false not null
);