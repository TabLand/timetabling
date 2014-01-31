<?php
	header('Content-type: text/javascript');
	include "simple_html_dom.php";
	include "modules.php";

	
	modules = new Modules;
	
	//"https://webapps.city.ac.uk/sst/vle/index.html?u="
	

		        $module_codes = "";
		        foreach($modules as $module_code => $module){
		        	$module_codes .=   ":" . $module_code;
		        }
			//why on earth?		        
		        $module_codes = substr($module_codes,1);
		        
		        $term_html = file_get_html("https://webapps.city.ac.uk/sst/vle/term.html?ms=" . $module_codes);
		        
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


?>
