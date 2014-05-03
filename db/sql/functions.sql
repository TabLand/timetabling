DELIMITER //

CREATE FUNCTION CheckClashes   (StartA DECIMAL(4,2), EndA DECIMAL(4,2)
                               ,StartB DECIMAL(4,2), EndB DECIMAL(4,2)
                               ,DayA   INT         , DayB INT       )
    RETURNS TINYINT(1)
    LANGUAGE SQL
BEGIN
    RETURN 
            (    (    EndA   >  StartB
                  AND EndA   <= EndB)
             OR (     EndB   >  StartA
                  AND EndB   <= EndA))
        AND DayA = DayB;
END//

CREATE FUNCTION SumPenaltiesRoomClash(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(CR.Penalty),0)
		FROM 
			ClashesRoom AS CR 
		WHERE 
			CR.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION SumPenaltiesRoomOverCapacity(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(ROC.Penalty),0)
		FROM 
			RoomOverCapacity AS ROC
		WHERE 
			ROC.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION SumPenaltiesStaffClash(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(CS.Penalty),0)
		FROM 
			ClashesStaff AS CS
		WHERE 
			CS.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION SumPenaltiesStudentClash(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(CS.Penalty),0)
		FROM 
			ClashesStudent AS CS
		WHERE 
			CS.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION SumPenaltiesStaffLunch(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(SLBC.Penalty),0)
		FROM 
			StaffLunchBreakClash AS SLBC
		WHERE 
			SLBC.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION SumPenaltiesStudentLunch(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
	DECLARE sum DOUBLE;
    SET sum = 
		(SELECT 
			COALESCE(SUM(SLBC.Penalty),0)
		FROM 
			StudentLunchBreakClash AS SLBC
		WHERE 
			SLBC.RevisionID = RevisionID);
	RETURN sum;
END//

CREATE FUNCTION ActivityPersonCount(ActivityID INT)
    RETURNS TINYINT(1)
    LANGUAGE SQL
BEGIN
    DECLARE person_count INT;
    SET person_count = (SELECT COUNT(ActivityID) FROM ActivityPerson AS AP WHERE AP.ActivityID=ActivityID);
    RETURN person_count;
END//

CREATE FUNCTION SumPenalties(RevisionID INT)
    RETURNS DOUBLE
    LANGUAGE SQL
BEGIN
    RETURN 
            SumPenaltiesRoomClash        (RevisionID)
        +   SumPenaltiesRoomOverCapacity (RevisionID)
        +   SumPenaltiesStaffClash       (RevisionID)
        +   SumPenaltiesStudentClash     (RevisionID)
        +   SumPenaltiesStaffLunch       (RevisionID)
        +   SumPenaltiesStudentLunch     (RevisionID);
END//

DELIMITER ;
