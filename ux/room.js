var data = [{room: "Great Hall", capacity: 300},
            {room: "Oliver Thompson", capacity: 200},
            {room: "C301", capacity: 30},
            {room: "A401a", capacity: 2}];

function get_columns(){
	return [{id: "room", name: "Room", field: "room" , editor: Slick.Editors.Text, width: "250"},
		{id: "capacity", name: "Capacity", field: "capacity", editor: Slick.Editors.Integer , width: "250"}];
}

function item_to_string(item){
    return item.room + "\t" + item.capacity + "\n";
}

function create_item(item, existing_item){
    if(not_defined(existing_item)) existing_item = dummy_item();
    var room = item[0] || existing_item.room;
    var capacity = item[1] || existing_item.capacity;
    return {"room": room, "capacity": capacity};
}

function dummy_item(){
    return {room: "", capacity: 0};
}

function is_dummy(item){
    if(not_defined(item)) return true;
    else {
        room_empty = item.room == "";
        capacity_empty = item.capacity == 0 || item.capacity == "";
        return room_empty && capacity_empty;
    }
}

function item_to_row(args){
    var new_room = args.item.room || "";
    var new_capacity = args.item.capacity || 0;
    return {room: new_room, capacity: new_capacity};
}
