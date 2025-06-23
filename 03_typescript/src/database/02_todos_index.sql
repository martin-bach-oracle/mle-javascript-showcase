-- liquibase formatted sql
-- changeset martin-bach-oracle:2

create index i_todos$sec1 on todos (name);