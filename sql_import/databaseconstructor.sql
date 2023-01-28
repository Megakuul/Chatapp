#Execute this file to create the database

CREATE DATABASE chatapp;

USE chatapp;

CREATE TABLE sessions (
	p_sessions_id int auto_increment not null,
    joincode varchar(5) not null,
    Primary Key(p_sessions_id)
);

CREATE TABLE message (
	p_message_id int auto_increment not null,
    message varchar(255) not null,
    creationtime datetime not null default NOW(),
    fk_sessions_id int not null,
	Primary Key (p_message_id),
    foreign key (fk_sessions_id) References sessions(p_sessions_id)
);

CREATE USER api IDENTIFIED WITH mysql_native_password BY 'sml12345';

GRANT SELECT, INSERT, DELETE ON * TO api;