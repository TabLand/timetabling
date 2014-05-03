DROP DATABASE Timetabling;
CREATE DATABASE Timetabling;
Use Timetabling;

CREATE TABLE Room (
	Code                VARCHAR(20),
	Capacity            INT,
	PRIMARY KEY (Code)
) ENGINE = INNODB;

CREATE TABLE Module (
	Code          VARCHAR(20),
	Name          VARCHAR(100),
	PRIMARY KEY(Code)
) ENGINE = INNODB;

CREATE TABLE Person (
	Username            VARCHAR(20) NOT NULL,
	Name                VARCHAR(50),
    Type                ENUM("Student","Staff"),
	PRIMARY KEY (Username)
) ENGINE = INNODB;

CREATE TABLE Activity (
    ActivityID          INT NOT NULL AUTO_INCREMENT,
    ModuleCode          VARCHAR(20),
    ActivityType        VARCHAR(20),
    ActivityGroup       VARCHAR(20),
    Duration            DECIMAL(4,2),
    UNIQUE INDEX (ModuleCode, ActivityType, ActivityGroup),
    FOREIGN KEY (ModuleCode) REFERENCES Module(Code) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (ActivityID)
) ENGINE = INNODB;

CREATE TABLE ActivityPerson(
    ActivityID          INT NOT NULL,
    Username            VARCHAR(20) NOT NULL,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Username)   REFERENCES Person(Username)     ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (ActivityID, Username)
) ENGINE = INNODB;

CREATE TABLE Constraints(
    ConstraintType      VARCHAR(20) NOT NULL,
    Penalty             DOUBLE,
    PRIMARY KEY (ConstraintType)
) ENGINE = INNODB;

CREATE TABLE TimetableHistory(
    RevisionID          INT NOT NULL AUTO_INCREMENT,
    ActivityID          INT,
    Start               DECIMAL(4,2),
    Day                 INT,
    RoomCode            VARCHAR(20),
    FOREIGN KEY (Day)        REFERENCES DayOfWeek(DayID)     ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (RoomCode)   REFERENCES Room(Code)           ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (RevisionID, ActivityID)
) ENGINE INNODB;

CREATE TABLE DayOfWeek(
    DayID   INT,
    Day     VARCHAR(9),
    PRIMARY KEY (DayID)
) ENGINE INNODB;

CREATE TABLE LunchBreak(
    Username    VARCHAR(20),
    RevisionID  INT,
    DayID       INT,
    Start       DECIMAL(4,2),
    FOREIGN KEY (DayID)    REFERENCES DayOfWeek(DayID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Username) REFERENCES Person(Username) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (Username, RevisionID, DayID)
) ENGINE INNODB;
