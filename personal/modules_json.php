<?php
	include "simple_html_dom.php";
	
	//by default we have succeeded in getting the module information
	$fail = false;
	$result = "";
	if(isset($_GET["username"])){
		//get module data
		$html = file_get_html("https://webapps.city.ac.uk/sst/vle/index.html?u=" . $_GET["username"]);
		$str = $html->save();;
		if(strpos($str,"Can't find student details") !== false){
			$fail = true;
			$error = "Invalid username. Could not find student details";
		}
		else{
			$modules = array();
			$keys = array("name","code","term","exam");
			$tds = $html->find("table tbody tr td");
			$count = 0;
			foreach($tds as $td){
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
		        $modules["status"] = "success";
		        $modules["error"] = "";
		        $result = json_encode($modules);
		}
	}
	else{
		$fail = true;
		$error = "Student username not given";
	}
	if($fail){
		$result = json_encode(array("status"=>"failure", "error"=$error);
	}
	echo $result;
?>
