var data = [{code: "IN3007", name: "Individual Project"},
            {code: "IN2029", name: "Programming in C++"}];

function get_columns(){
	return [{id: "code", name: "Module Code", field: "code" , editor: Slick.Editors.Text, width: "250"},
            {id: "name", name: "Module Name", field: "name" , editor: Slick.Editors.Text, width: "250"}];
}

function item_to_string(item){
    return item.code + "\t" + item.name + "\n";
}

function create_item(item, existing_item){
    if(not_defined(existing_item)) existing_item = dummy_item();
    var code = item[0] || existing_item.code;
    var name = item[1] || existing_item.name;
    return {"code": code, "name": name};
}

function dummy_item(){
    return {code: "", name: ""};
}

function is_dummy(item){
    if(not_defined(item)) return true;
    else {
        code_empty = item.code == "";
        name_empty = item.name == "";
        return code_empty && name_empty;
    }
}
function item_to_row(args){
    var new_code = args.item.code || "";
    var new_name = args.item.name || "";
    return {code: new_code, name: new_name};
}
