function activity(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

activity.prototype.get_columns = function(){
	return [{id: "id", name: "Id", field: "id" , editor: Slick.Editors.Number},
            {id: "code", name: "Module Code", field: "code" , editor: Slick.Editors.Text},
            {id: "type", name: "Activity Type", field: "type" , editor: Slick.Editors.Text},
            {id: "group", name: "Group Name", field: "group" , editor: Slick.Editors.Text},
            {id: "duration", name: "Duration", field: "duration" , editor: Slick.Editors.Text},];
}

activity.prototype.item_to_string = function(item){
    return item.code + "\t" + item.type + "\t" + item.group + "\t" + item.duration + "\n";
}

activity.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var code = item[0] || existing_item.code;
    var type = item[1] || existing_item.type;
    var group = item[2] || existing_item.group;
    var duration = item[3] || existing_item.duration;
    return {"id": id, "code": code, "type": type, "group": group, "duration": duration};
}

activity.prototype.dummy_item = function(){
    return {id: 0, code: "", type: "", group: "", duration: ""};
}

activity.prototype.set_item = function(item, new_item){
    item.code = new_item.code;
    item.type = new_item.type;
    item.group = new_item.group;
    item.duration = new_item.duration;
}

activity.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var code_empty = item.code == "";
        var type_empty = item.type == "";
        var group_empty = item.group == "";
        var duration_empty = item.duration == "";

        return code_empty && type_empty && group_empty && duration_empty;
    }
}

activity.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_code = args.item.code || "";
    var new_type = args.item.type || "";
    var new_group = args.item.group || "";
    var new_duration = args.item.duration || "";
    return {id: new_id, code: new_code, type: new_type, group: new_group, duration: new_duration};
}

activity.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../Activity.xml", this.get_process_xml_function_ref(this));
}

activity.prototype.get_process_xml_function_ref = function(activity_ref){
    return function(data){
        var xml_root = data.children[0];
        activity_list = xml_root.children;
        activity_ref._data_view.beginUpdate();
        for(i = 0; i < activity_list.length; i++){
            activity_node = activity_list[i];
            var code = html_helpers.get_xml_node_data(activity_node.children[0]);
            var type = html_helpers.get_xml_node_data(activity_node.children[1]);
            var group = html_helpers.get_xml_node_data(activity_node.children[2]);
            var duration = html_helpers.get_xml_node_data(activity_node.children[3]);
            var my_activity = [code, type, group, duration];
            var activity_item = activity_ref.create_item(my_activity,null);
            activity_ref._data_view.addItem(activity_item);
        }
        activity_ref._data_view.endUpdate();
        activity_ref._data_view.refresh_grid();
    }
}

activity.prototype.save_all = function(xml_out){
    $.post( "../ActivityUpdater.pl",{"xml": xml_out});
}

activity.prototype.get_xml_from_grid = function(){
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
activity.prototype.fill_auto_complete = function(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"] = item_field_to_array(items, "name");
}

activity_spreadsheet = new spreadsheet(new activity());
