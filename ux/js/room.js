function room(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
};

room.prototype.get_columns = function(){
	return [{id: "code", name: "Room Code", field: "code" , editor: Slick.Editors.Text},
    		{id: "capacity", name: "Capacity", field: "capacity", editor: Slick.Editors.Integer},
           ];
}

room.prototype.check_duplicate_primary_keys = function(){
    var rooms = this._data_view.getItems();
    var room_codes = Array();

    for(var i =0; i<room.length; i++){
        room_codes.push(rooms[i].code);
    }

    var duplicates = html_helpers.check_duplicates(room_codes);
    
    if(duplicates.exist){
        alert("Invalid Room Code \"" + duplicates.culprit + "\"! Room codes must be unique!");
    }
    return duplicates.exist;
}

room.prototype.validate_all_items = function(){
    var rooms = this._data_view.getItems();
    var valid = true;

    for(i=0; i<rooms.length; i++){
        var room = rooms[i];
        var valid_room_code     = this.validate_code(room.code);
        var valid_room_capacity = this.validate_capacity(room.capacity);
        valid &= (valid_room_capacity && valid_room_capacity);
    }
    return valid;
}

room.prototype.validate_code = function(code){
    var contains_invalid_symbols = /[^A-Za-z0-9]/;
    if(contains_invalid_symbols.test(code)){
        alert("Room code \"" + code + "\" contains invalid symbols." 
               + " Only letters and numbers are allowed in Room Code!");
        return false;
    }
    else return true;
}

room.prototype.validate_capacity = function(capacity){
    if(capacity<0){
        alert("Capacity cannot be negative!");
        return false;
    }
    else return true;
}

room.prototype.item_to_string = function(item){
    return item.code + "\t" + item.capacity + "\n";
}

room.prototype.clone = function(room){
    var cloned_room = {};
    
    if( typeof room == "undefined" ) {
        return this.dummy_item();
    }
    else{
        cloned_room.id = room.id || 0;
        cloned_room.code = room.code || "";
        cloned_room.capacity = room.capacity || 0;
        return cloned_room;
    }
}

room.prototype.equals = function(first, second){
    var same_capacity = first.capacity == second.capacity;
    var same_code = first.code == second.code;
    return same_capacity && same_code;
}

room.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var code     = item[0] || existing_item.code;
    var capacity = item[1] || existing_item.capacity;
    return {"id":id, "code": code, "capacity": capacity};
}

room.prototype.dummy_item = function(){
    return {id: 0, room: "", capacity: 0};
}

room.prototype.set_item = function(item, new_item){
    item.code = new_item.code;
    item.capacity = new_item.capacity;
}

room.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        var code_empty = item.code == "";
        var capacity_empty = item.capacity == 0 || item.capacity == "";
        return code_empty && capacity_empty;
    }
}

room.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_code = args.item.code || "";
    var new_capacity = args.item.capacity || 0;
    return {id: new_id, code: new_code, capacity: new_capacity};
}

room.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../db/RoomList.pl", this.get_process_input_function_ref(this));
}

room.prototype.get_process_input_function_ref = function(room_ref){
    return function(data){
        room_list = data;
        room_ref._data_view.beginUpdate();
        for(i = 0; i < room_list.length; i++){
            var my_room = room_list[i];
            var room_group = [my_room.code, my_room.capacity];
            var room_item = room_ref.create_item(room_group, null);
            room_ref._data_view.addItem(room_item);
        }
        room_ref._data_view.endUpdate();
        room_ref._data_view.refresh_grid();
    }
}

room.prototype.save_all = function(json){
    $.post( "../db/RoomUpdater.pl",{"changes": json});
}

room_spreadsheet = new spreadsheet(new room());
