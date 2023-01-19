#Execute this file to create the database
#If the connection to the database from nodejs doesnt work, you have to execute the code below to the user your connecting to
#ALTER USER 'api'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

CREATE DATABASE chatapp;

USE chatapp;

CREATE TABLE sessions (
	p_sessions_id int auto_increment not null,
    joincode int not null,
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