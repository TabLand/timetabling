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
    FOREIGN KEY (ActivityID) REFERENCES Activity(ActivityID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (RoomCode)   REFERENCES Room(Code)           ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (RevisionID, ActivityID)
) ENGINE INNODB;

DELIMITER //

CREATE VIEW SchedulableActivities AS
    SELECT 
        DISTINCT ActivityID
    FROM
        ActivityPerson;

CREATE FUNCTION CheckClashes   (StartA DECIMAL(4,2), EndA DECIMAL(4,2)
                               ,StartB DECIMAL(4,2), EndB DECIMAL(4,2)
                               ,DayA   INT         , DayB INT
                               ,IDA    INT         , IDB  INT        )
    RETURNS TINYINT(1)
    LANGUAGE SQL
BEGIN
    RETURN 
            IDA    != IDB
        AND (    (    EndA   >  StartB
                  AND EndA   <= EndB)
             OR (     EndB   >  StartA
                  AND EndB   <= EndA))
        AND DayA = DayB;
END//

CREATE VIEW RoomActivityBookings AS
    SELECT 
		T.ActivityID, T.Start, (T.Start + A.Duration) AS Finish, T.RoomCode, T.RevisionID, T.Day, A.Duration
    FROM 
		TimetableHistory AS T, Activity AS A
	WHERE 
		T.ActivityID = A.ActivityID;

CREATE VIEW PersonActivityBookings AS
    SELECT
        T.ActivityID, T.Start, (T.Start + A.Duration) AS Finish, T.RevisionID, T.Day, A.Duration, AP.Username
    FROM
        TimetableHistory AS T, Activity AS A, ActivityPerson AS AP
    WHERE
            T.ActivityID  = A.ActivityID
        AND AP.ActivityID = A.ActivityID;

CREATE VIEW ClashesRoom AS
    SELECT 
        A.ActivityID, A.Start, A.Finish, A.RoomCode, A.RevisionID, A.Day, A.Duration
    FROM
        RoomActivityBookings AS A, 
        RoomActivityBookings AS B
    WHERE
            CheckClashes(A.Start, A.Finish, B.Start, B.Finish, A.Day, B.Day, A.ActivityID, B.ActivityID)
        AND A.RevisionID = B.RevisionID
        AND A.RoomCode   = B.RoomCode;

CREATE VIEW ClashesPerson AS
    SELECT
        A.ActivityID, A.Start, A.Finish, A.RevisionID, A.Day, A.Duration, A.Username
    FROM
        PersonActivityBookings AS A, 
        PersonActivityBookings AS B
    WHERE
            CheckClashes(A.Start, A.Finish, B.Start, B.Finish, A.Day, B.Day, A.ActivityID, B.ActivityID)
        AND A.RevisionID = B.RevisionID
        AND A.Username   = B.Username;

CREATE FUNCTION RoomClashesCount (RoomCode VARCHAR(20), RevisionID INT)
    RETURNS INT
    LANGUAGE SQL
BEGIN
    DECLARE clashes_count INT;
    SET clashes_count = (
        SELECT 
            COUNT(CR.ActivityID) 
        FROM 
            ClashesRoom AS CR
        WHERE
                CR.RoomCode   = RoomCode
            AND CR.RevisionID = RevisionID);
	RETURN clashes_count;
END//


CREATE FUNCTION PersonClashesCount (Username VARCHAR(20), RevisionID INT)
    RETURNS INT
    LANGUAGE SQL
BEGIN
    DECLARE clashes_count INT;
    SET clashes_count = (
        SELECT
            COUNT(CP.ActivityID)
        FROM
            ClashesPerson AS CP
        WHERE
                CP.Username   = Username
            AND CP.RevisionID = RevisionID);
    RETURN clashes_count;
END//

CREATE FUNCTION PersonClashesCountLatest (Username VARCHAR(20))
    RETURNS INT
    LANGUAGE SQL
BEGIN
	DECLARE revision INT;
    SET revision = (SELECT MAX(RevisionID) FROM TimetableHistory);
    RETURN PersonClashesCount(Username, revision);    
END//

CREATE FUNCTION RoomClashesCountLatest (RoomCode VARCHAR(20))
    RETURNS INT
    LANGUAGE SQL
BEGIN
    DECLARE revision INT;
    SET revision = (SELECT MAX(RevisionID) FROM TimetableHistory);
    RETURN RoomClashesCount(RoomCode, revision);    
END//

CREATE VIEW RoomOverbook AS
    SELECT 
        RAB.ActivityID, R.Code, (R.Capacity < ActivityPersonCount(RAB.ActivityID))
    FROM
        Room AS R, RoomActivityBookings AS RAB
    WHERE
            R.Code = RAB.RoomCode;

CREATE FUNCTION NoLunchBreak (Username VARCHAR(20)
    RETURNS TINYINT(1)
    LANGUAGE SQL
BEGIN
    
END//

CREATE FUNCTION ActivityPersonCount(ActivityID INT)
    RETURNS TINYINT(1)
    LANGUAGE SQL
BEGIN
    DECLARE person_count INT;
    SET person_count = (SELECT COUNT(ActivityID) FROM ActivityPerson AS AP WHERE AP.ActivityID=ActivityID);
    RETURN person_count;
END//

DELIMITER ;
