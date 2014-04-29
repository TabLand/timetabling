function activity(){
    this.data          = [];
    this._data_view    = null;
    this._spreadsheet  = null;
    this._module_codes = [];
}

activity.prototype.get_columns = function(){
	return [{id: "code"    , name: "Module Code"  , field: "code"     , editor: this.get_module_acomplete_editor()},
            {id: "type"    , name: "Activity Type", field: "type"     , editor: Slick.Editors.Text},
            {id: "group"   , name: "Group Name"   , field: "group"    , editor: Slick.Editors.Text},
            {id: "duration", name: "Duration"     , field: "duration" , editor: Slick.Editors.Text},];
}

activity.prototype.get_module_acomplete_editor = function(){
    $.get("../db/ModuleList.pl", this.get_populate_module_codes_function_ref(this));
    return Slick.Editors.AutoSetup(this._module_codes);
}

activity.prototype.get_populate_module_codes_function_ref = function(activity_ref){
    return function(data){
        var module_list = data;
        for(i=0; i<module_list.length; i++){
            var module = module_list[i];
            activity_ref._module_codes.push(module.code);
        }
    }    
}

activity.prototype.check_duplicate_primary_keys = function(){
    var activities             = this._data_view.getItems();
    var valid                  = true;
    var activity_tuple_strings = Array();

    for(i=0; i<activities.length; i++){
        var activity = activities[i];
        activity_tuple_strings.push(activity.code + "-" + activity.type + "-" + activity.group);
    }

    duplicates = html_helpers.check_duplicates(activity_tuple_strings);
    
    if(duplicates.exist){
        alert("Invalid Activity Tuple \""+ duplicates.culprit +"\"! Activity Tuples (ModuleCode+Type+Group) must be unique!");
    }
    return duplicates.exist;
}

activity.prototype.validate_all_items = function(){
    var activities = this._data_view.getItems();
    var valid = true;
    for(i=0; i<activities.length; i++){
        var activity          = activities[i];
        var valid_type        = this.validate_text(activity.type, "type");
        var valid_group       = this.validate_text(activity.group, "group");
        var valid_duration    = this.validate_duration(activity.duration);
        var valid_module_code = this.validate_module_code(activity.code);
        valid &= (valid_type && valid_group && valid_duration && valid_module_code);
    }
    return valid;
}

activity.prototype.validate_text = function(text, field){
    var contains_invalid_symbols = /[^A-Za-z]/;
    if(contains_invalid_symbols.test(text)){
        alert("Activity " + field + " value:\"" + text + "\" contains invalid characters, Only letters allowed");
        return false;
    }
    else return true;
}

activity.prototype.validate_module_code = function(code){
    if(this._module_codes.indexOf(code) == -1){
        alert("Module code " + code + " is invalid, pick something in the list!!");
        return false;
    }
    else return true;
}

activity.prototype.validate_duration = function(duration){
    var duration_array = duration.split(":");
    if(duration_array.length != 2){
        alert("invalid duration entered, format is HH:MM!!");
        return false;
    }
    var hours = parseInt(duration_array[0]);
    var minutes = parseInt(duration_array[1]);
    if(isNaN(hours) || isNaN(minutes)){
        alert("invalid duration entered, format is HH:MM!!");
        return false;
    }
    else return true;
}

activity.prototype.item_to_string = function(item){
    return item.code + "\t" + item.type + "\t" + item.group + "\t" + item.duration + "\n";
}

activity.prototype.clone = function(activity){
    var cloned_activity = {};
    
    if( typeof activity == "undefined" ) {
        return this.dummy_item();
    }
    else{
        cloned_activity.id       = activity.id       || 0;
        cloned_activity.code     = activity.code     || "";
        cloned_activity.group    = activity.group    || "";
        cloned_activity.type     = activity.type     || "";
        cloned_activity.duration = activity.duration || "02:00";
        return cloned_activity;
    }
}

activity.prototype.equals = function(first, second){
    var same_code     = first.code     == second.code;
    var same_type     = first.type     == second.type;
    var same_group    = first.group    == second.group;
    var same_duration = first.duration == second.duration;

    return same_code && same_type && same_group && same_duration;
}

activity.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();

    var id       = this._spreadsheet.get_next_id();
    var code     = item.code     || existing_item.code;
    var type     = item.type     || existing_item.type;
    var group    = item.group    || existing_item.group;
    var duration = item.duration || existing_item.duration;

    return {"id": id, "code": code, "type": type, "group": group, "duration": duration};
}

activity.prototype.dummy_item = function(){
    return {id: 0, code: "", type: "", group: "", duration: "02:00"};
}

activity.prototype.set_item = function(item, new_item){
    item.code     = new_item.code;
    item.type     = new_item.type;
    item.group    = new_item.group;
    item.duration = new_item.duration;
}

activity.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var code_empty     = item.code     == "";
        var type_empty     = item.type     == "";
        var group_empty    = item.group    == "";

        return code_empty && type_empty && group_empty;
    }
}

activity.prototype.item_to_row = function(args){
    var new_id       = args.item.id       || this._spreadsheet.get_next_id();
    var new_code     = args.item.code     || "";
    var new_type     = args.item.type     || "";
    var new_group    = args.item.group    || "";
    var new_duration = args.item.duration || "";

    return {id: new_id, code: new_code, type: new_type, group: new_group, duration: new_duration};
}

activity.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/ActivityList.pl", this.get_process_input_function_ref(this));
}

activity.prototype.get_process_input_function_ref = function(activity_ref){
    return function(data){
        var activity_list = data;
        activity_ref._data_view.beginUpdate();

        for(i = 0; i < activity_list.length; i++){
            var my_activity    = activity_list[i];
            var activity_item  = activity_ref.create_item(my_activity,null);
            activity_ref._data_view.addItem(activity_item);
        }

        activity_ref._data_view.endUpdate();
        activity_ref._data_view.refresh_grid();
    }
}

activity.prototype.save_all = function(json){
    $.post( "../db/ActivityUpdater.pl",{"changes": json});
}

//move to activity
activity.prototype.fill_auto_complete = function(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"]     = item_field_to_array(items, "name");
}

activity_spreadsheet = new spreadsheet(new activity());
