CREATE DATABASE treemanager;
USE treemanager;
CREATE USER 'www'@'localhost';

/* Create node table to persist items of tree */
CREATE TABLE treemanager.node (
        idnode int NOT NULL AUTO_INCREMENT COMMENT 'Node identifier created from sequence',
	idparent int NULL COMMENT 'identifer of parent node',
	lval int NOT NULL COMMENT 'DFS left value (used to colorize tree)',
	rval int NOT NULL COMMENT 'DFS right value (used to colorize tree)',
	state int not null COMMENT 'Record status (1.bit updated, 2.bit deleted)',
	stateuser int not null COMMENT 'Modified by',
	statestamp TIMESTAMP not null COMMENT 'Modified at',
	PRIMARY KEY (idnode)
);
GRANT SELECT, NODE ON treemanager.node TO "www"@"localhost";

/* Create user table for authorization */
CREATE TABLE treemanager.user (
        iduser int NOT NULL AUTO_INCREMENT COMMENT 'User identifier created from sequence',
	username varchar(255) NULL COMMENT 'Username',
	signature varchar(255) NULL COMMENT 'Long name of user',
	PRIMARY KEY (iduser)
);
GRANT SELECT, INSERT, UPDATE ON treemanager.user TO "www"@"localhost";

/* Create table to save revision of node */
CREATE TABLE treemanager.revision (
	idnode int NOT NULL COMMENT 'Row identifier',
	alldata varchar(4096) COMMENT 'Row data',
	state int not null COMMENT 'Record status (1.bit updated, 2.bit deleted)',
	stateuser int not null COMMENT 'Modified by',
	statestamp TIMESTAMP not null COMMENT 'Modified at'
);
GRANT SELECT, INSERT ON treemanager.revision TO "www"@"localhost";

/* Create first user */
INSERT INTO user values(1, 'norbert', 'Norbert Volf');

/* Create sequence table */
CREATE TABLE node_sequence (id INT NOT NULL);
INSERT INTO node_sequence VALUES (0);
GRANT SELECT, UPDATE ON treemanager.node_sequence TO "www"@"localhost";
