CREATE DATABASE treemanager;
USE treemanager;
CREATE USER 'www'@'localhost';
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
GRANT SELECT ON treemanager.node TO "www"@"localhost";

CREATE TABLE treemanager.user (
        iduser int NOT NULL AUTO_INCREMENT COMMENT 'User identifier created from sequence',
	username varchar(255) NULL COMMENT 'Username',
	PRIMARY KEY (iduser)
);
GRANT SELECT, INSERT, UPDATE ON treemanager.user TO "www"@"localhost";

CREATE TABLE treemanager.revision (
	idnode int NOT NULL COMMENT 'Row identifier',
	alldata varchar(4096) COMMENT 'Row data',
	state int not null COMMENT 'Record status (1.bit updated, 2.bit deleted)',
	stateuser int not null COMMENT 'Modified by',
	statestamp TIMESTAMP not null COMMENT 'Modified at'
);
GRANT SELECT, INSERT ON treemanager.revision TO "www"@"localhost";
