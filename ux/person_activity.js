function person_activity(){
    this.data = [];
    this._data_view       = null;
    this._spreadsheet     = null;
    this._people          = Array();
    this._activities      = Array();
    this._person_editor   = null;
    this._activity_editor = null;
    this.setup_editors();
}

person_activity.prototype.get_columns = function(){
	return [{id: "activity", name: "Activity", field: "activity" , editor: this._activity_editor},
            {id: "person"  , name: "Person"  , field: "person"   , editor: this._person_editor},];
}

person_activity.prototype.setup_editors = function(){
    $.get("../db/PersonList.pl"  , this.get_populate_person_usernames_function_ref(this));
    $.get("../db/ActivityList.pl", this.get_populate_activity_tuples_function_ref(this));
    this._activity_editor = Slick.Editors.AutoSetup(this._activities);
    this._person_editor   = Slick.Editors.AutoSetup(this._people);
}

person_activity.prototype.get_populate_person_usernames_function_ref = function(activity_ref){
    return function(data){
        var people = data;
        for(i=0; i<people.length; i++){
            var person = people[i];
            activity_ref._people.push(person.username);
        }
    }    
}

person_activity.prototype.get_populate_activity_tuples_function_ref = function(activity_ref){
    return function(data){
        var activities = data;
        for(i=0; i<activities.length; i++){
            var activity = activities[i];
            activity_ref._activities.push(activity.code + "-" + activity.type + "-" + activity.group);
        }
    }    
}

person_activity.prototype.check_duplicate_primary_keys = function(){
    var people_activities    = this._data_view.getItems();
    var p_a_tuples = Array();

    for(var i =0; i<people_activities.length; i++){
        var p_a = people_activities[i];
        p_a_tuples.push(p_a.person + "-" + p_a.activity);
    }

    var duplicates = html_helpers.check_duplicates(p_a_tuples);
    
    if(duplicates.exist){
        alert("Invalid Person Activity Grouping \""+ duplicates.culprit +"\"! Person Activity Groupings must be unique!");
    }
    return duplicates.exist;
}

person_activity.prototype.validate_all_items = function(){
    var people_activities = this._data_view.getItems();
    var is_valid = true;
    for(i=0; i<people_activities.length; i++){
        var p_a            = people_activities[i];
        var valid_person   = this.validate_person(p_a.person);
        var valid_activity = this.validate_activity(p_a.activity);
        is_valid &= (valid_person && valid_activity);
    }
    return is_valid;
}

person_activity.prototype.validate_person = function(person){
    if(this._people.indexOf(person) == -1){
        alert("Username " + person + " is invalid, pick something in the list!!");
        return false;
    }
    else return true;
}

person_activity.prototype.validate_activity = function(activity_tuple){
    if(this._activities.indexOf(activity_tuple) == -1){
        alert("Activity tuple " + activity_tuple + " is invalid, pick something in the list!!");
        return false;
    }
    else return true;
}

person_activity.prototype.item_to_string = function(item){
    return item.activity + "\t" + item.person + "\n";
}

person_activity.prototype.clone = function(person_activity){
    var cloned_person_activity = {};
    
    if( typeof person_activity == "undefined" ) {
        return this.dummy_item();
    }
    else{
        cloned_person_activity.id       = person_activity.id       || 0;
        cloned_person_activity.person   = person_activity.person   || "";
        cloned_person_activity.activity = person_activity.activity || "";
        return cloned_person_activity;
    }
}

person_activity.prototype.equals = function(first, second){
    var same_person   = first.person   == second.person;
    var same_activity = first.activity == second.activity;

    return same_person && same_activity;
}

person_activity.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id       = this._spreadsheet.get_next_id();
    var activity = item[0] || existing_item.activity;
    var person   = item[1] || existing_item.person;
    return {"id": id, "activity": activity, "person": person,};
}

person_activity.prototype.dummy_item = function(){
    return {id: 0, activity: "", person: "",};
}

person_activity.prototype.set_item = function(item, new_item){
    item.activity = new_item.activity;
    item.person   = new_item.person;
}

person_activity.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var activity_empty = item.activity == "";
        var person_empty   = item.person   == "";
        return activity_empty && person_empty;
    }
}

person_activity.prototype.item_to_row = function(args){
    var new_id       = args.item.id       || this._spreadsheet.get_next_id();
    var new_activity = args.item.activity || "";
    var new_person   = args.item.person   || "";
    return {id: new_id, activity: new_activity, person: new_person,};
}

person_activity.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/PersonActivityList.pl", this.get_process_input_function_ref(this));
}

person_activity.prototype.get_process_input_function_ref = function(person_activity_ref){
    return function(data){
        person_activity_list = data;
        person_activity_ref._data_view.beginUpdate();

        for(i = 0; i < activity_list.length; i++){
            var person_activity      = activity_list[i];
            var person_activity_item = create_item(person_activity, null);
            this._data.view.addItem(person_activity_item);
        }

        person_activity_ref._data_view.endUpdate();
        person_activity_ref._data_view.refresh_grid();
    }
}

person_activity.prototype.save_all = function(json){
    $.post( "../db/PersonActivityUpdater.pl",{"changes": json});
}


person_activity_spreadsheet = new spreadsheet(new person_activity());
