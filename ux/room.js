function room(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
};

room.prototype.get_columns = function(){
	return [{id: "id", name: "Id", field: "id" , editor: Slick.Editors.Number, width: "20"},
            {id: "room", name: "Room", field: "room" , editor: Slick.Editors.Text, width: "240"},
    		{id: "capacity", name: "Capacity", field: "capacity", editor: Slick.Editors.Integer , width: "240"}];
}

room.prototype.item_to_string = function(item){
    return item.room + "\t" + item.capacity + "\n";
}

room.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var room = item[0] || existing_item.room;
    var capacity = item[1] || existing_item.capacity;
    return {"id":id, "room": room, "capacity": capacity};
}

room.prototype.dummy_item = function(){
    return {id: 0, room: "", capacity: 0};
}

room.prototype.set_item = function(item, new_item){
    item.room = new_item.room;
    item.capacity = new_item.capacity;
}

room.prototype.is_dummy = function(item){
    if(this._spreadsheet.not_defined(item)) return true;
    else {
        room_empty = item.room == "";
        capacity_empty = item.capacity == 0 || item.capacity == "";
        return room_empty && capacity_empty;
    }
}

room.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_room = args.item.room || "";
    var new_capacity = args.item.capacity || 0;
    return {id: new_id, room: new_room, capacity: new_capacity};
}

room.prototype.populate = function(){
    this._spreadsheet.empty_data_view();
    $.get("../Rooms.xml", this.get_process_xml_function_ref(this));
}

room.prototype.get_process_xml_function_ref = function(room_ref){
    return function(data){
        var xml_root = data.children[0];
        room_list = xml_root.children;
        room_ref._data_view.beginUpdate();
        for(i = 0; i < room_list.length; i++){
            room_node = room_list[i];
            var room_code = html_helpers.get_xml_node_data(room_node.children[0]);
            var room_capacity = html_helpers.get_xml_node_data(room_node.children[1]);
            var room = [room_code, room_capacity];
            var room_item = room_ref.create_item(room,null);
            room_ref._data_view.addItem(room_item);
        }
        room_ref._data_view.endUpdate();
        room_ref._data_view.refresh_grid();
    }
}

room.prototype.save_all = function(xml_out){
    $.post( "../RoomUpdater.pl",{"xml": xml_out});
}

room.prototype.get_xml_from_grid = function(){
    var rooms = this._data_view.getItems();
    var xml_out = '<?xml version="1.0" ?>';
    xml_out += "\n<Rooms>"
    for(i in rooms){
        var my_room = rooms[i];
        xml_out += "\n\t<Room>";
        xml_out += "\n\t\t<Code>" + my_room.room + "</Code>";
        xml_out += "\n\t\t<Capacity>" + my_room.capacity + "</Capacity>";
        xml_out += "\n\t</Room>";
    }
    xml_out += "\n</Rooms>"
    return xml_out;
}

room_spreadsheet = new spreadsheet(room);
