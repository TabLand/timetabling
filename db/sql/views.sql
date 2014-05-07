CREATE VIEW SchedulableActivities AS
    SELECT 
        DISTINCT ActivityID
    FROM
        ActivityPerson;

CREATE VIEW RoomActivityBookings AS
    SELECT 
		T.ActivityID, T.Start, (T.Start + A.Duration) AS Finish
        , T.RoomCode, T.RevisionID, T.Day, A.Duration
        , SumPenalties(T.RevisionID) AS Penalties
    FROM 
		TimetableHistory AS T, Activity AS A
	WHERE 
		T.ActivityID = A.ActivityID;

CREATE VIEW PersonActivityBookings AS
    SELECT
        T.ActivityID, T.Start, (T.Start + A.Duration) AS Finish
        , T.RevisionID, T.Day, A.Duration, AP.Username
        , SumPenalties(T.RevisionID) AS Penalties
    FROM
        TimetableHistory AS T, Activity AS A, ActivityPerson AS AP
    WHERE
            T.ActivityID  = A.ActivityID
        AND AP.ActivityID = A.ActivityID;

CREATE VIEW ClashesRoom AS
    SELECT 
        A.ActivityID, A.Start, A.Finish, A.RoomCode, A.RevisionID, A.Day, A.Duration, C.Penalty
    FROM
        RoomActivityBookings AS A, 
        RoomActivityBookings AS B,
        Constraints          AS C
    WHERE
            CheckClashes(A.Start, A.Finish, B.Start, B.Finish, A.Day, B.Day)
        AND A.RevisionID     =  B.RevisionID
        AND A.RoomCode       =  B.RoomCode
        AND C.ConstraintType =  "RoomDoubleBooking"
        AND A.ActivityID     != B.ActivityID;

CREATE VIEW ClashesPerson AS
    SELECT
        A.ActivityID, A.Start, A.Finish, A.RevisionID, A.Day, A.Duration, A.Username, P.Type
    FROM
        PersonActivityBookings AS A, 
        PersonActivityBookings AS B,
        Person                 AS P
    WHERE
            CheckClashes(A.Start, A.Finish, B.Start, B.Finish, A.Day, B.Day)
        AND A.RevisionID =  B.RevisionID
        AND A.Username   =  B.Username
        AND P.Username   =  A.Username
        AND A.ActivityID != B.ActivityID;

CREATE VIEW ClashesStaff AS
    SELECT
        CP.ActivityID, CP.Start, CP.Finish, CP.RevisionID, CP.Day, CP.Duration, CP.Username, C.Penalty
    FROM
        ClashesPerson AS CP,
        Constraints   AS C
    WHERE
            CP.Type          = "Staff"
        AND C.ConstraintType = "StaffDoubleBooking";

CREATE VIEW ClashesStudent AS
    SELECT
        CP.ActivityID, CP.Start, CP.Finish, CP.RevisionID, CP.Day, CP.Duration, CP.Username, C.Penalty
    FROM
        ClashesPerson AS CP,
        Constraints   AS C
    WHERE
            CP.Type          = "Student"
        AND C.ConstraintType = "StudentDoubleBooking";

CREATE VIEW RoomOverCapacity AS
    SELECT 
        RAB.ActivityID, R.Code, C.Penalty, RAB.RevisionID, R.Capacity AS Capacity
        , ActivityPersonCount(RAB.ActivityID) AS CapacityNeeded
    FROM
        Room AS R, RoomActivityBookings AS RAB, Constraints AS C
    WHERE
            R.Code           = RAB.RoomCode
        AND C.ConstraintType = "RoomOverCapacity"
        AND R.Capacity < ActivityPersonCount(RAB.ActivityID);

CREATE VIEW LunchBreaks AS
    SELECT 
        *, (Start+1) AS Finish
    FROM 
        LunchBreak;

CREATE VIEW LunchBreakClash AS
    SELECT 
        LB.Username, P.Type, LB.DayID, PAB.ActivityID, PAB.RevisionID
    FROM
        LunchBreaks AS LB, PersonActivityBookings AS PAB, Person AS P
    WHERE
            LB.Username  = PAB.Username
        AND PAB.Username = P.Username
        AND PAB.RevisionID = LB.RevisionID
        AND CheckClashes(LB.Start, LB.Finish, PAB.Start, PAB.Finish, LB.DayID, PAB.Day);

CREATE VIEW StaffLunchBreakClash AS
    SELECT
       LBC.Username, LBC.DayID, LBC.ActivityID, C.Penalty, LBC.RevisionID
    FROM
        LunchBreakClash AS LBC, Constraints AS C
    WHERE
            C.ConstraintType = "StaffLunch"
		AND LBC.Type         = "Staff";

CREATE VIEW StudentLunchBreakClash AS
    SELECT
       LBC.Username, LBC.DayID, LBC.ActivityID, C.Penalty, LBC.RevisionID
    FROM
        LunchBreakClash AS LBC, Constraints AS C
    WHERE
            C.ConstraintType = "StudentLunch"
		AND LBC.Type         = "Student";

CREATE VIEW LatestPersonActivityBookings AS
    SELECT 
        * 
    FROM
        PersonActivityBookings
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestPersonLunchBreaks AS
    SELECT
        *
    FROM
        LunchBreak 
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestRoomActivityBookings AS
    SELECT
        *
    FROM
        RoomActivityBookings
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestRoomClashes AS
    SELECT
        *
    FROM
        ClashesRoom
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestRoomOverCapacity AS
    SELECT
        *
    FROM
        RoomOverCapacity
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestStudentClashActivities AS
    SELECT
        *
    FROM
        ClashesStudent
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestStaffClashActivities AS
    SELECT
        *
    FROM
        ClashesStaff
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestStudentLunchClashes AS
    SELECT
        *
    FROM
        StudentLunchBreakClash
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW LatestStaffLunchClashes AS
    SELECT
        *
    FROM
        StaffLunchBreakClash
    WHERE
        RevisionID = LatestRevision();

CREATE VIEW RoomReplacements AS
    SELECT 
	    R.Code, A.ActivityID
    FROM 
    	Room AS R, Activity AS A
    WHERE
	    ActivityPersonCount(A.ActivityID) <= R.Capacity;

CREATE VIEW DebugPenalties AS
    SELECT 
        DISTINCT RevisionID, 
        SumPenalties                 (RevisionID)
       ,SumPenaltiesRoomClash        (RevisionID)
       ,SumPenaltiesRoomOverCapacity (RevisionID)
       ,SumPenaltiesStaffClash       (RevisionID)
       ,SumPenaltiesStudentClash     (RevisionID)
       ,SumPenaltiesStaffLunch       (RevisionID)
       ,SumPenaltiesStudentLunch     (RevisionID)
	FROM
		TimetableHistory;
