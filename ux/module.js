function module(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

module.prototype.get_columns = function(){
	return [{id: "id", name: "Id", field: "id" , editor: Slick.Editors.Number, width: "20"},
            {id: "code", name: "Module Code", field: "code" , editor: Slick.Editors.Text, width: "240"},
            {id: "name", name: "Module Name", field: "name" , editor: Slick.Editors.Text, width: "240"}];
}

module.prototype.item_to_string = function(item){
    return item.code + "\t" + item.name + "\n";
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
    $.get("../Modules.xml", this.get_process_xml_function_ref(this));
}

module.prototype.get_process_xml_function_ref = function(module_ref){
    return function(data){
        var xml_root = data.children[0];
        module_list = xml_root.children;
        module_ref._data_view.beginUpdate();
        for(i = 0; i < module_list.length; i++){
            module_node = module_list[i];
            var module_name = html_helpers.get_xml_node_data(module_node.children[0]);
            var module_code = html_helpers.get_xml_node_data(module_node.children[1]);
            var module = [module_code, module_name];
            var module_item = module_ref.create_item(module,null);
            module_ref._data_view.addItem(module_item);
        }
        module_ref._data_view.endUpdate();
        module_ref._data_view.refresh_grid();
    }
}

module.prototype.save_all = function(xml_out){
    $.post( "../ModuleUpdater.pl",{"xml": xml_out});
}

module.prototype.get_xml_from_grid = function(){
    var modules = this._data_view.getItems();
    var xml_out = '<?xml version="1.0" ?>';
    xml_out += "\n<Modules>"
    for(i in modules){
        var my_module = modules[i];
        xml_out += "\n\t<Module>";
        xml_out += "\n\t\t<Name>" + my_module.name + "</Name>";
        xml_out += "\n\t\t<Code>" + my_module.code + "</Code>";
        xml_out += "\n\t</Module>";
    }
    xml_out += "\n</Modules>"
    return xml_out;
}

module_spreadsheet = new spreadsheet(module);
