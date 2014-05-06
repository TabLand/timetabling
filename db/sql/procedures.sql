DELIMITER //
CREATE PROCEDURE InitialiseTimetableHistory()
BEGIN
    DECLARE room_code VARCHAR(20);
    SET room_code = (SELECT Code FROM Room LIMIT 1);
    DELETE FROM TimetableHistory;
    INSERT INTO 
        TimetableHistory (RevisionID, ActivityID, Start, Day, RoomCode)
        SELECT 
             1 AS RevisionID
            ,ActivityID
            ,9 AS Start
            ,1 AS Day
            ,room_code AS Room
        FROM 
            SchedulableActivities;
END//

CREATE PROCEDURE InitialiseLunchBreaks()
BEGIN
    DELETE FROM LunchBreak;
    INSERT INTO
        LunchBreak (Username, RevisionID, DayID, Start) 
        SELECT 
             P.Username
            ,1 AS RevisionID
            , D.DayID
            , 12 AS Start  
        FROM Person AS P, DayOfWeek AS D;
END//

CREATE PROCEDURE IncrementTimetableRevision()
BEGIN
    DECLARE max_revision INT;
    SET max_revision 
        = (SELECT 
                MAX(RevisionID) 
           FROM 
                TimetableHistory);
    INSERT INTO 
        TimetableHistory (RevisionID, ActivityID, Start, Day, RoomCode)
        SELECT 
            (RevisionID+1),ActivityID,Start, Day, RoomCode
        FROM  TimetableHistory
        WHERE RevisionID = max_revision;
END//

CREATE PROCEDURE IncrementLunchBreakRevision()
BEGIN
    DECLARE max_revision INT;
    SET max_revision 
        = (SELECT 
                MAX(RevisionID) 
           FROM 
                LunchBreak);
    INSERT INTO 
        LunchBreak (Username, RevisionID, DayID, Start)
        SELECT 
            Username, (RevisionID+1), DayID, Start
        FROM  LunchBreak
        WHERE RevisionID = max_revision;
END//

DELIMITER ;
