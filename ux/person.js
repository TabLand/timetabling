var data = [{username: "abnd198", name: "Ijtaba Hussain"},
            {username: "root", name: "Linus Torvalds"}];

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
    var username = item[0] || existing_item.username;
    var name = item[1] || existing_item.name;
    return {"username": username, "name": name};
}

function dummy_item(){
    return {username: "", name: ""};
}

function is_dummy(item){
    if(not_defined(item)) return true;
    else {
        username_empty = item.username == "";
        name_empty = item.name == "";
        return username_empty && name_empty;
    }
}

function item_to_row(args){
    var new_username = args.item.username || "";
    var new_name = args.item.name || "";
    return {username: new_username, name: new_name};

function fill_auto_complete(){
    var items = data_view.getItems();
    autocomplete_data["username"] = item_field_to_array(items, "username");
    autocomplete_data["name"] = item_field_to_array(items, "name");
}
