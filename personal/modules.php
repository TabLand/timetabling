<?php
//This class extensively uses C.Marshal's web apps script
class Modules{
    //success by default
    public $fail = false;
    public $result = "";
    public $error = "";
    public $html_dom;
    public $html_dump;
    public $modules = array();
    public $return_dates = array();
    
    //in milliseconds
    const one_day = 86400;
    const one_week = 604800;
    
    private function get_page($url){
        $this->html_dom = file_get_html($url);
        $this->html_dump = $this->html_dom->save();
    }
    
    private function validate_username(){
        $html_dump = $this->get_dump();

        if(strpos($html_dump,"Can't find student details") !== false){
            $this->fail = true;
            $this->error .= "Invalid username. Could not find student details";
        }
    }

    //what modules does the student study?
    private function get_student_info(){
        //"https://webapps.city.ac.uk/sst/vle/index.html?u="
    }
    private function parse_student(){
        foreach($html_dom->find("table tbody tr") as $table_row){
            parse_student_table_row($table_row);
        }
    }
    private function parse_student_table_row($table_row){
        $tds = $table_row->find("td");
        $this->parse_student_tds($tds);
    }
    private function parse_student_tds($tds){
        for($td_pos = 0; $td_pos < sizeof($tds); $td_pos++ ){
            switch($td_pos){
                case 0:
                   $module_name = $table_data->plaintext;
                case 1:
                   $module_code = $table_data->plaintext;
                case 2:
                    $module_term = $table_data->plaintext;
            }
        }
        if(isset($module_code)){
            $this->modules[$module_code]["name"] = $module_name;
            $this->modules[$module_code]["term"] = $module_term;
        }
    }
    
    private function fill_dates($dates, $day){
	
        $date_ranges = explode(",",$dates);
        
        foreach($date_ranges as $date_range){
            //for each range, there are three cases
            $from_tos = explode("-",$date_range);
            //1)Either one or more ranges of start date -> end date
            if(sizeof($from_tos)==2){
		$this->fill_start_to_end($from_tos);
	    }
            //2)Only a single date
            elseif(sizeof($from_tos)==1){
		$this->no_fill($from_tos);
            }
            //3)Malformed date - return false in this case
            else $this->return_dates =  false;
        }
        return $this->return_dates;
    }
    
    private function fill_start_to_end($from_tos){
        $from = conv_date($from_tos[0]);
	$to = conv_date($from_tos[1]);
        
        $date = $this->shift_day_of_week($from, $day);
        $date = $this->shift_day_of_week($to, $day);
        
	while($from <= $to){
            $this->return_dates[] = pretty_date($from);
            $from += one_week;
	}
    }
    private function no_fill($dates,$day){
        $date = conv_date($dates[0]);
        $date = $this->shift_day_of_week($date, $day);
        $this->return_dates[] = $this->pretty_date($date);
    }
    private function shift_day_of_week($date, $day){
        while(day_of_week($date) != $day){
	    $date += one_day;
	}
        return $date;
    }
    private function pretty_date($date){
        return date("d-M-Y",$date);
    }
    private function day_of_week($date){
        return date("l",$date);
    }
    private function conv_date($date){
		$split = explode("/",$date);
		return mktime(0,0,0,$split[1],$split[0],$split[2]);
    }	
    private function build_module_list(){
        $module_codes = "";
	foreach($this->modules as $module_code => $module){
            $module_codes .=   ":" . $module_code;
	}
        //there is one extra ":" at the start of module codes, chop it off
	$module_codes = substr($module_codes,1);
        return $module_codes;
    }
    private function get_modules_info(){
        $this->get_page("https://webapps.city.ac.uk/sst/vle/term.html?ms=".build_module_list());
        $this->parse_modules();
    }
    private function parse_modules(){
        foreach($html_dom->find("table tbody tr") as $mod_row){
                parse_module_table_row($mod_row);
        }
    }
    private function add_booking($module_code,  $group, $starttime, $endtime, $location, $day, $dates){
        //dates need to be split by comma
	//then all dates need to be matched to $day by incrementing by a maximum of 6
	//then dates need to be seperated by "-", and gaps need to be filled in.
	$booking = array();
	$booking["group"] = $group;
	$booking["starttime"] = $starttime;
	$booking["endtime"] = $endtime;
	$booking["location"] = $location;
	$booking["day"] = $day;
        ///???
	//add error checking if statement here
	$booking["dates"] = fill_dates($dates, $day);
	if($booking["dates"]===false) $error .= " Malformed date provided. Dump $dates. ";
	$modules[$module_code]["timetable"][] = $booking;
    }
    private function parse_module_table_row($table_row){
        $days = ["Monday","Tuesday", "Wednesday","Thursday","Friday","Saturday","Sunday"];
        //validate input to make sure a valid week day is given
        $day_temp = trim($table_row->plaintext);
        if(in_array($day_temp, $days)){
            $day = $day_temp;
        }
        
        unset($module_code);
        $module_tds = $table_row->find("td");
        for($td_pos = 0; $td_pos<sizeof($module_tds); $td_pos++){
            switch($td_pos){
                case 0: $starttime = $module_tds[$td_pos]_data->plaintext; break;
                case 1: $endtime = $module_tds[$td_pos]->plaintext; break;
                case 2: $module_code = $module_tds[$td_pos]->plaintext; break;
                case 3: $group = $module_tds[$td_pos]->plaintext; break;
                case 4: $location = $module_tds[$td_pos]->plaintext; break;
                case 5: $dates = $module_tds[$td_pos]->plaintext; break;
            }
        }
            if(isset($module_code)){
		$this->add_booking($module_code, $group, $starttime, $endtime, $location, $day, $dates);
    }
    private function parse_module_tds($tds){
        
    }
    //grab scheduling and location information of modules being studied
    
}
?>