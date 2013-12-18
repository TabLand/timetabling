<?php
	header('Content-type: text/javascript');
	include "simple_html_dom.php";
	
	//by default we have succeeded in getting the module information
	$fail = false;
	$result = "";
	$error = "";
	if(isset($_GET["username"])){
		//get module data
		$html = file_get_html("https://webapps.city.ac.uk/sst/vle/index.html?u=" . $_GET["username"]);
		$str = $html->save();;
		if(strpos($str,"Can't find student details") !== false){
			$fail = true;
			$error .= "Invalid username. Could not find student details";
		}
		else{
			$modules = array();
			$return = array();
			$tr = 0;
			foreach($html->find("table tbody tr") as $trow){
				$td = 0;
				foreach($trow->find("td") as $tdata){
					
					switch($td){
					case 0:
				        	$mod_name = $tdata->plaintext;
					case 1:
				        	$mod_code = $tdata->plaintext;
					case 2:
						$mod_term = $tdata->plaintext;
					}
					$td++;
				}
				if(isset($mod_code)){
					$modules[$mod_code]["name"] = $mod_name;
					$modules[$mod_code]["term"] = $mod_term;
				}
				$tr++;
			}
		        $module_codes = "";
		        foreach($modules as $module_code => $module){
		        	$module_codes .=   ":" . $module_code;
		        }
		        $module_codes = substr($module_codes,1);
		        
		        $term_html = file_get_html("https://webapps.city.ac.uk/sst/vle/term.html?ms=" . $module_codes);
		        foreach($term_html->find("table tbody tr") as $term_row){
		        	switch((trim($term_row->plaintext))){
		        		case "Monday":	$day = "Monday"; break;
			        	case "Tuesday": $day = "Tuesday"; break;
			        	case "Wednesday": $day = "Wednesday"; break;
			        	case "Thursday": $day = "Thursday"; break;
			        	case "Friday": $day = "Friday"; break;
			        	case "Saturday": $day = "Saturday"; break;
			        	case "Sunday": $day = "Sunday"; break;
		        	}
				$td = 0;
				unset($module_code);
				foreach($term_row->find("td") as $term_data){
					switch($td){
						case 0: $starttime = $term_data->plaintext; break;
						case 1: $endtime = $term_data->plaintext; break;
						case 2: $module_code = $term_data->plaintext; break;
						case 3: $group = $term_data->plaintext; break;
						case 4: $location = $term_data->plaintext; break;
						case 5: $dates = $term_data->plaintext; break;
					}
					$td++;
				}
				if(isset($module_code)){
					//dates need to be split by comma
					//then all dates need to be matched to $day by incrementing by a maximum of 6
					//then dates need to be seperated by "-", and gaps need to be filled in.
					$booking = array();
					$booking["group"] = $group;
					$booking["starttime"] = $starttime;
					$booking["endtime"] = $endtime;
					$booking["location"] = $location;
					$booking["day"] = $day;
					//add error checking if statement here
					$booking["dates"] = fill_dates($dates, $day);
					if($booking["dates"]===false) $error .= " Malformed date provided. Dump $dates. ";
					$modules[$module_code]["timetable"][] = $booking;
				}
		        }
			$return["status"] = "success";
		        $return["error"] = $error;
       		        $return["modules"] = $modules;
		        $result = json_encode($return, JSON_PRETTY_PRINT);
		}
	}
	else{
		$fail = true;
		$error .= "Student username not given";
	}
	if($fail){
		$result = json_encode(array("status"=>"failure", "error"=>$error));
	}
	echo $result;

function fill_dates($dates, $day){
	//three cases. 
	//1)Either one or more ranges of from to tos
	//2)Only a single date
	//3)Malformed date - return false in this case
	$date_ranges = explode(",",$dates);
	$ret_dates = array();

	foreach($date_ranges as $date_range){
		$from_tos = explode("-",$date_range);
		if(sizeof($from_tos)==2){
			$from = conv_date($from_tos[0]);
			$to = conv_date($from_tos[1]);
			
			while(date("l",$from) != $day){
				if($day_counter >5) {
					$ret_dates = false;
				}
				else{
					$from += 60*60*24;
					$to += 60*60*24;
				}
			}
			while($from <= $to){
				$ret_dates[] = date("d-M-Y",$from);
				$from += 60*60*24*7;
			}
		}
		elseif(sizeof($from_tos)==1){
			$from = conv_date($from_tos[0]);
			//make sure loop does not loop over a week
			$day_counter = 0;
			while(date("l",$from) != $day){
				if($day_counter >5) {
					$ret_dates = false;
				}
				else{
					$from += 60*60*24;
				}
			}
			$ret_dates[] = date("d-M-Y",$from);
		}
		else $ret_dates =  false;
	}
	return $ret_dates;
}
function conv_date($date){
	$split = explode("/",$date);
	return mktime(0,0,0,$split[1],$split[0],$split[2]);
}
?>
