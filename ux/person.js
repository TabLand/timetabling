var data = [{id: 0, username: "abnd198", name: "Ijtaba Hussain"},
            {id: 1, username: "root", name: "Linus Torvalds"}];

var autocomplete_data = [];

function get_columns(){
	return [{id: "id", name: "ID", field: "id" , editor: Slick.Editors.Number, width: "20"},
            {id: "username", name: "Username", field: "username" , editor: Slick.Editors.Auto, width: "240"},
            {id: "name", name: "Name", field: "name" , editor: Slick.Editors.Auto, width: "240"},
           ];
}

function item_to_string(item){
    return item.username + "\t" + item.name + "\n";
}

function create_item(item, existing_item){
    if(not_defined(existing_item)) existing_item = dummy_item();
    var id = get_next_id();
    var username = item[0] || existing_item.username;
    var name = item[1] || existing_item.name;
    return {"id": id, "username": username, "name": name};
}

function get_next_id(){
    var items = data_view.getItems();
    var ids = items.map(get_item_id);
    var max = Math.max.apply(null, ids);
    return max + 1;
}

function get_item_id(item){
    return item.id;
}

function dummy_item(){
    return {id: 0, username: "", name: ""};
}

function set_item(item, new_item){
    item.username = new_item.username;
    item.name = new_item.name;
}

function set_dummy_item(item){
    set_item(item, dummy_item());
}

function is_dummy(item){
    if(not_defined(item)) return true;
    else {
        var username_empty = item.username == "";
        var name_empty = item.name == "";
        return username_empty && name_empty;
    }
}

function populate(){
    $.get("../Staff.xml", process_xml);
}

function process_xml(data){
    var xml_root = data.children[0];
    staff_list = xml_root.children;
    data_view.beginUpdate();
    for(i = 0; i < staff_list.length; i++){
        staff_node = staff_list[i];
        var staff_name = staff_node.children[0].firstChild.data;
        var staff_code = staff_node.children[1].firstChild.data;
        var staff = [staff_code, staff_name];
        var staff_item = create_item(staff,null);
        data_view.addItem(staff_item);
    }
    data_view.endUpdate();
    refresh_grid();
}

function item_to_row(args){
    var new_id = args.item.id || get_next_id();
    var new_username = args.item.username || "";
    var new_name = args.item.name || "";
    return {id: new_id, username: new_username, name: new_name};
}

function fill_auto_complete(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"] = item_field_to_array(items, "name");
}
