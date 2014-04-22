function person(writer_path,reader_path){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
    this.writer_path = writer_path;
    this.reader_path = reader_path;
};

person.prototype.get_columns = function(){
	return [{id: "id", name: "Id", field: "id" , editor: Slick.Editors.Number, width: "20"},
            {id: "username", name: "Username", field: "username" , editor: Slick.Editors.Text, width: "240"},
            {id: "name", name: "Name", field: "name" , editor: Slick.Editors.Text, width: "240"},
           ];
}

person.prototype.item_to_string = function(item){
    return item.username + "\t" + item.name + "\n";
}

person.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var username = item[0] || existing_item.username;
    var name = item[1] || existing_item.name;
    return {"id": id, "username": username, "name": name};
}

person.prototype.dummy_item = function(){
    return {id: 0, username: "", name: ""};
}

person.prototype.set_item = function(item, new_item){
    item.username = new_item.username;
    item.name = new_item.name;
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
    return {id: new_id, username: new_username, name: new_name};
}

person.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get(this.reader_path, this.get_process_xml_function_ref(this));
}

person.prototype.get_process_xml_function_ref = function(person_ref){
    return function(data){
        var xml_root = data.children[0];
        var person_list = xml_root.children;
        person_ref._data_view.beginUpdate();
        for(i = 0; i < person_list.length; i++){
            person_node = person_list[i];
            var person_name = html_helpers.get_xml_node_data(person_node.children[0]);
            var person_username = html_helpers.get_xml_node_data(person_node.children[1]);
            var my_person = [person_username, person_name];
            var person_item = person_ref.create_item(my_person,null);
            person_ref._data_view.addItem(person_item);
        }
        person_ref._data_view.endUpdate();
        person_ref._data_view.refresh_grid();
    }
}

person.prototype.save_all = function(xml_out){
    $.post(this.writer_path,{"xml": xml_out});
}

person.prototype.get_xml_from_grid = function(){
    var people = this._data_view.getItems();
    var xml_out = '<?xml version="1.0" ?>';
    xml_out += "\n<People>"
    for(i in people){
        var my_person = people[i];
        xml_out += "\n\t<Person>";
        xml_out += "\n\t\t<Name>" + my_person.name + "</Name>";
        xml_out += "\n\t\t<Username>" + my_person.username + "</Username>";
        xml_out += "\n\t</Person>";
    }
    xml_out += "\n</People>"
    return xml_out;
}

//move to activity
person.prototype.fill_auto_complete = function(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"] = item_field_to_array(items, "name");
}
