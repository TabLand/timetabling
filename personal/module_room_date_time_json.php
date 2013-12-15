<?php
	include "simple_html_dom.php";
	
	//by default we have succeeded in getting the module information
	$fail = false;
	$result = "";
	if(isset($_GET["module"])){
		//get module data
		$html = file_get_html("http://webapps.city.ac.uk/sst/vle/term.html?t=all&o=AJ&ms=" . $_GET["module"]);
		$str = $html->save();;
		if(strpos($str,"We currently have no time table for this set of modules") !== false){
			$fail = true;
			$error = "Invalid Module code. Could not find module timetable";
		}
		else{
			$modules = array();
			$return = array();
			$tds = $html->find("table tbody tr td");
			$count = 0;
			/*foreach($tds as $td){
				switch($count % 4){
					case 0:
				        	$modules[floor($count/4)]["name"] = $td->find("a",0)->innertext;
					case 1:
				        	$modules[floor($count/4)]["code"] = $td->find("a",0)->innertext;
					case 2:
						$modules[floor($count/4)]["term"] = $td->find("a",0)->innertext;
				}
		        	$count++;
		        }
		        $return["status"] = "success";
		        $return["error"] = "";
		        $return["modules"] = $modules;
		        $result = json_encode($return);*/
		}
	}
	else{
		$fail = true;
		$error = "Module code not given";
	}
	if($fail){
		$result = json_encode(array("status"=>"failure", "error"=>$error));
	}
	echo $result;
?>
