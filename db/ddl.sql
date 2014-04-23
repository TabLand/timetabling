DROP DATABASE Timetabling;
CREATE DATABASE Timetabling;
Use Timetabling;

CREATE TABLE Room (
	Code                VARCHAR(20),
	Capacity            INT,
	PRIMARY KEY (Code)
) ENGINE = INNODB;

CREATE TABLE Module (
	ModuleCode          VARCHAR(20),
	ModuleName          VARCHAR(100),
	PRIMARY KEY(ModuleCode)
) ENGINE = INNODB;

CREATE TABLE Staff (
	Username            VARCHAR(20) NOT NULL,
	Name                VARCHAR(50),
	PRIMARY KEY (Username)
) ENGINE = INNODB;

CREATE TABLE Student (
	Username            VARCHAR(20) NOT NULL,
	Name                VARCHAR(50),
	PRIMARY KEY (Username)
) ENGINE = INNODB;

CREATE TABLE Activity (
    ActivityID          INT NOT NULL AUTO_INCREMENT,
    ModuleCode          VARCHAR(20),
    ActivityType        VARCHAR(20),
    ActivityGroup       VARCHAR(20),
    DurationHours       INT,
    DurationMinutes     INT,
    UNIQUE INDEX (ModuleCode, ActivityType, ActivityGroup),
    FOREIGN KEY (ModuleCode) REFERENCES Module(ModuleCode) ON UPDATE NO ACTION ON DELETE CASCADE,
    PRIMARY KEY (ActivityID)
) ENGINE = INNODB;

CREATE TABLE ActivityStaff(
    ActivityID          INT NOT NULL,
    Username            VARCHAR(20) NOT NULL,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (Username) REFERENCES Staff(Username) ON UPDATE NO ACTION ON DELETE CASCADE,
    PRIMARY KEY (ActivityID, Username)
) ENGINE = INNODB;

CREATE TABLE ActivityStudents(
    ActivityID          INT NOT NULL,
    Username            VARCHAR(20) NOT NULL,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (Username) REFERENCES Student(Username) ON UPDATE NO ACTION ON DELETE CASCADE,
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
    StartHour           INT,
    StartMinute         INT,
    Day                 INT,
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE NO ACTION ON DELETE CASCADE,
    PRIMARY KEY (RevisionID, ActivityID)
)
