function module(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

module.prototype.get_columns = function(){
	return [{id: "code", name: "Module Code", field: "code" , editor: Slick.Editors.Text},
            {id: "name", name: "Module Name", field: "name" , editor: Slick.Editors.Text}];
}

module.prototype.check_duplicate_primary_keys = function(module){
    var modules = this._data_view.getItems();
    var module_codes = Array();

    for(var i =0; i<modules.length; i++){
        module_codes.push(modules[i].code);
    }

    var duplicates = html_helpers.check_duplicates(module_codes);

    if(duplicates.exist){
        alert("Invalid Module Code \""+ duplicates.culprit +"\"! Module codes must be unique!");
    }
    return duplicates.exist;
}

module.prototype.validate_all_items = function(){
    var invalid_code = /[^A-Za-z0-9\#\&\-]/;
    var invalid_name = /[^A-Za-z\ ]/;

    culprit = null;
    var modules = this._data_view.getItems();

    for(i=0; i<modules.length; i++){
        var my_module = modules[i];

        if(invalid_code.test(my_module.code)){
            alert("Invalid Module code! " + my_module.code + " Module code can only contain letters"
                  + ", numbers and the symbols #&- and no spaces");
            return false;
        }
        else if(invalid_name.test(my_module.name)){
            alert("Invalid Module name! " + my_module.name + " Module name can only contain letters"
                  + " and spaces");
            return false;
        }
    }
    return true;
}

module.prototype.item_to_string = function(item){
    return item.code + "\t" + item.name + "\n";
}

module.prototype.clone = function(module){
    var cloned_module = {};
    
    if( typeof module == "undefined" ) {
        return this.dummy_item();
    }
    else{
        cloned_module.id = module.id || 0;
        cloned_module.code = module.code || "";
        cloned_module.name = module.name || "";
        return cloned_module;
    }
}

module.prototype.equals = function(first, second){
    var same_name = first.name == second.name;
    var same_code = first.code == second.code;
    return same_name && same_code;
}

module.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var code = item[0] || existing_item.code;
    var name = item[1] || existing_item.name;
    return {"id": id, "code": code, "name": name};
}

module.prototype.dummy_item = function(){
    return {id: 0, code: "", name: ""};
}

module.prototype.set_item = function(item, new_item){
    item.code = new_item.code;
    item.name = new_item.name;
}

module.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var code_empty = item.code == "";
        var name_empty = item.name == "";
        return code_empty && name_empty;
    }
}

module.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_code = args.item.code || "";
    var new_name = args.item.name || "";
    return {id: new_id, code: new_code, name: new_name};
}

module.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/ModuleList.pl", this.get_process_input_function_ref(this));
}

module.prototype.get_process_input_function_ref = function(module_ref){
    return function(data){

        var module_list = data;
        module_ref._data_view.beginUpdate();

        for(var i=0; i < module_list.length; i++){
            var module = module_list[i];
            var module_item = module_ref.create_item([module.code,module.name],null);
            module_ref._data_view.addItem(module_item);
        }

        module_ref._data_view.endUpdate();
        module_ref._data_view.refresh_grid();
    }
}

module.prototype.save_all = function(json){
    $.post( "../db/ModuleUpdater.pl",{"changes": json});
}

module_spreadsheet = new spreadsheet(new module());
