<?php
require_once("timetable.php");
header ( 'Content-type: text/javascript' );
$my_timetable = new Timetable ();
echo $my_timetable->get_timetable($_GET["username"]);
?>