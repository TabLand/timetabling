function viewer(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

viewer.prototype.get_columns = function(){
	return [{id: "code", name: "Resource Code", field: "code" , editor: Slick.Editors.Text},
            {id: "type", name: "Resource Type", field: "type" , editor: Slick.Editors.Text}];
}

viewer.prototype.check_duplicate_primary_keys = function(viewer){
    //stub
}

viewer.prototype.validate_all_items = function(){
    //stub
}

viewer.prototype.item_to_string = function(item){
    //stub
}

viewer.prototype.clone = function(item){
    //stub
}

viewer.prototype.equals = function(first, second){
    //stub
}

viewer.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var code = item[0] || existing_item.code;
    var type = item[1] || existing_item.type;
    return {"id": id, "code": code, "type": type};
}

viewer.prototype.dummy_item = function(){
    return {id: 0, code: "", type: ""};
}

viewer.prototype.set_item = function(item, new_item){
    //stub
}

viewer.prototype.is_dummy = function(item){
    //stub
}

viewer.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_code = args.item.code || "";
    var new_type = args.item.type || "";
    return {id: new_id, code: new_code, type: new_type};
}

viewer.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/PersonList.pl", this.fill_persons(this));
    $.get("../db/RoomList.pl", this.fill_rooms(this));
}

viewer.prototype.fill_persons = function(viewer_ref){
    return function(data){
        var people_list = data;
        viewer_ref._data_view.beginUpdate();

        for(var i=0; i < people_list.length; i++){
            var person = people_list[i];
            var person_item = viewer_ref.create_item([person.username,person.type],null);
            viewer_ref._data_view.addItem(person_item);
        }

        viewer_ref._data_view.endUpdate();
        viewer_ref._data_view.refresh_grid();
    }
}

viewer.prototype.fill_rooms = function(viewer_ref){
    return function(data){
        var rooms_list = data;
        viewer_ref._data_view.beginUpdate();

        for(var i=0; i < rooms_list.length; i++){
            var room = rooms_list[i];
            var room_item = viewer_ref.create_item([room.code,"Room"],null);
            viewer_ref._data_view.addItem(room_item);
        }

        viewer_ref._data_view.endUpdate();
        viewer_ref._data_view.refresh_grid();
    }
}

viewer.prototype.save_all = function(json){
    //stub
}

viewer_spreadsheet = new spreadsheet(new viewer());
viewer_spreadsheet.options.editable = false;
