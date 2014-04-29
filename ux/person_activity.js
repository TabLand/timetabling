function staff_activity(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

staff_staff_activity.prototype.get_columns = function(){
	return [{id: "id", name: "Id", field: "id" , editor: Slick.Editors.Number},
            {id: "activity", name: "Activity", field: "activity" , editor: Slick.Editors.Text},
            {id: "staff", name: "Staff", field: "staff" , editor: Slick.Editors.Text},];
}

staff_activity.prototype.item_to_string = function(item){
    return item.activity + "\t" + item.staff + "\n";
}

staff_activity.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var activity = item[0] || existing_item.code;
    var staff = item[1] || existing_item.type;
    return {"id": id, "activity": activity, "staff": staff,};
}

staff_activity.prototype.dummy_item = function(){
    return {id: 0, activity: "", staff: "",};
}

staff_activity.prototype.set_item = function(item, new_item){
    item.activity = new_item.activity;
    item.staff = new_item.staff;
}

staff_activity.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var activity_empty = item.code == "";
        var staff_empty = item.type == "";
        return activity_empty && staff_empty;
    }
}

staff_activity.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_activity = args.item.activity || "";
    var new_staff = args.item.staff || "";
    return {id: new_id, activity: new_activity, staff: new_staff,};
}

staff_activity.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../StaffActivity.xml", this.get_process_xml_function_ref(this));
}

staff_activity.prototype.get_process_xml_function_ref = function(staff_activity_ref){
    return function(data){
        var xml_root = data.children[0];
        staff_activity_list = xml_root.children;
        staff_activity_ref._data_view.beginUpdate();
        for(i = 0; i < activity_list.length; i++){
            staff_activity_node = activity_list[i];
            var activity = html_helpers.get_xml_node_data(activity_node.children[0]);
            var staff = html_helpers.get_xml_node_data(activity_node.children[1]);
            var my_staff_activity = [activity, staff,];
            var staff_activity_item = staff_activity_ref.create_item(my_staff_activity,null);
            staff_activity_ref._data_view.addItem(staff_activity_item);
        }
        staff_activity_ref._data_view.endUpdate();
        staff_activity_ref._data_view.refresh_grid();
    }
}

staff_activity.prototype.save_all = function(xml_out){
    $.post( "../StaffActivityUpdater.pl",{"xml": xml_out});
}

staff_activity.prototype.get_xml_from_grid = function(){
    var activities = this._data_view.getItems();
    var xml_out = '<?xml version="1.0" ?>';
    xml_out += "\n<Activities>"
    for(i in activities){
        var my_activity = activities[i];
        xml_out += "\n\t<Activity>";
        xml_out += "\n\t\t<Code>" + my_module.code + "</Code>";
        xml_out += "\n\t\t<Type>" + my_module.type + "</Type>";
        xml_out += "\n\t\t<Group>" + my_module.group + "</Group>";
        xml_out += "\n\t\t<Duration>" + my_module.duration + "</Duration>";
        xml_out += "\n\t</Activity>";
    }
    xml_out += "\n</Activities>"
    return xml_out;
}

//move to activity
staff_activity.prototype.fill_auto_complete = function(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"] = item_field_to_array(items, "name");
}

activity_spreadsheet = new spreadsheet(new activity());
