function person(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
};

person.prototype.get_columns = function(){
	return [{id: "username", name: "Username", field: "username" , editor: Slick.Editors.Text},
            {id: "name", name: "Name", field: "name" , editor: Slick.Editors.Text},
            {id: "type", name: "Type", field: "type" , editor: Slick.Editors.Text},
           ];
}

person.prototype.check_duplicate_primary_keys = function(){
    var people    = this._data_view.getItems();
    var usernames = Array();

    for(var i =0; i<people.length; i++){
        usernames.push(people[i].username);
    }

    var duplicates = html_helpers.check_duplicates(usernames);
    
    if(duplicates.exist){
        alert("Invalid Username \""+ duplicate.culprit +"\"! Usernames must be unique!");
    }
    return duplicates.exist;
}

person.prototype.item_to_string = function(item){
    return item.username + "\t" + item.name + "\t" + item.type + "\n";
}

person.prototype.validate_all_items = function(){
    var people = this._data_view.getItems();
    var valid = true;
    for(i=0; i<people.length; i++){
        var person = people[i];
        valid &= this.validate_person(person);
    }
    return valid;
}

person.prototype.validate_person = function(person){
    valid_username = this.validate_username(person.username);
    valid_name     = this.validate_name(person.name);
    person.type    = this.get_validated_type(person.type);
    return valid_username && valid_name;
}

person.prototype.validate_username = function(username){
    var contains_invalid_username = /[^A-Za-z0-9]/;
    if(contains_invalid_username.test(username)){
        alert("\"" + person.username + "\" contains invalid symbols." 
              + " Only letters and numbers are allowed in Username!");
        return false;
    }
    else return true;
}

person.prototype.validate_name = function(name){
    var contains_invalid_name = /[^A-Za-z\ ]/;
    if(contains_invalid_name.test(name)) {
        alert("\"" + name + "\" contains invalid symbols." 
               + " Only letters and spaces are allowed! in Name");
        return false;
    }
    else return true;
}

person.prototype.get_validated_type = function(type){
    if(!(type == "Staff" || type == "Student")){
        return "Student";
    }
    else return type;
}

person.prototype.clone = function(person){
    var cloned_person = {};
    
    if( typeof person == "undefined" ) {
        return this.dummy_item();
    }
    else{
        cloned_person.id = person.id || 0;
        cloned_person.username = person.username || "";
        cloned_person.name = person.name || "";
        cloned_person.type = person.type || "Student";
        return cloned_person;
    }
}

person.prototype.equals = function(first, second){
    var same_name = first.name == second.name;
    var same_username = first.username == second.username;
    var same_type = first.type == second.type;
    return same_name && same_username && same_type;
}

person.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var username = item[0] || existing_item.username;
    var name     = item[1] || existing_item.name;
    var type     = item[2] || existing_item.type;
    return {"id": id, "username": username, "name": name, "type":type};
}

person.prototype.dummy_item = function(){
    return {id: 0, username: "", name: "", type: "Student"};
}

person.prototype.set_item = function(item, new_item){
    item.username = new_item.username;
    item.name = new_item.name;
    item.type = new_item.type;
}

person.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var username_empty = item.username == "";
        var name_empty = item.name == "";
        return username_empty && name_empty;
    }
}

person.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_username = args.item.username || "";
    var new_name = args.item.name || "";
    var new_type = args.item.type || "Student";
    return {id: new_id, username: new_username, name: new_name, type: new_type};
}

person.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/PersonList.pl", this.get_process_input_function_ref(this));
}

person.prototype.get_process_input_function_ref = function(person_ref){
    return function(data){
        var person_list = data;
        person_ref._data_view.beginUpdate();

        for(i = 0; i < person_list.length; i++){
            var my_person = person_list[i];
            var person_group = [my_person.username, my_person.name, my_person.type];
            var person_item = person_ref.create_item(person_group,null);
            person_ref._data_view.addItem(person_item);
        }

        person_ref._data_view.endUpdate();
        person_ref._data_view.refresh_grid();
    }
}

person.prototype.save_all = function(json){
    $.post("../db/PersonUpdater.pl",{"changes": json});
}

person_spreadsheet = new spreadsheet(new person());
