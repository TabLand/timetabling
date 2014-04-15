var grid;
var pressed = {};

function formatter(row, cell, value, columnDef, dataContext) {
    return value;
}

var options = {
    editable: true,
    enableCellNavigation: true,
    enableColumnReorder: false,
    autoEdit: false,
    enableAddRow: true,
};

var data = [];
for (var i = 0; i < 5; i++) {
	data[i] = {room: "C301", capacity: 33};
}

function initialise_grid(){
	var columns = get_columns();
	grid = new Slick.Grid("#entry", data, columns, options);
    grid.setSelectionModel(new Slick.RowSelectionModel());
    grid.onAddNewRow.subscribe(add_row);
    grid.onKeyDown.subscribe(key_down);
    grid.onKeyUp.subscribe(key_up);
}

function get_columns(){
	return [{id: "room", name: "Room", field: "room" , editor: Slick.Editors.Text, width: 250},
		{id: "capacity", name: "Capacity", field: "capacity", editor: Slick.Editors.Integer , width: 250}];
}

function add_row(e,args){
    new_room = args.item.room || "";
    new_capacity = args.item.capacity || 0;
    row = {room: new_room, capacity: new_capacity};
    console.log(row);
    data.push(row);
    grid.updateRowCount();
    grid.invalidate();
    grid.render();
}

function remove_row(){
    data.pop();
    grid.updateRowCount()
    grid.render();
}
function key_down(e,args){
    //ctrl key
    if(e.keyCode == 17) pressed["ctrl"] = true;
    pressed["c"] = e.keyCode == 67;
    pressed["v"] = e.keyCode == 86;

    if(pressed["c"] && pressed["ctrl"] && !pressed["copy"]){
        pressed["copy"] = true;
        get_selection();
    }

    if(pressed["v"] && pressed["ctrl"] && !pressed["paste"]){
        pressed["paste"] = true;
        clipboard = $("textarea#clipboard")[0];
        clipboard.select();
        set_timeout
        pasted_text = $("textarea#clipboard")[0].value;
        console.log("just pasted" + pasted_text);
    }
}
function key_up(e,args){
    if(e.keyCode == 17){
        pressed["ctrl"] = false;
        pressed["copy"] = false;
    }
    else if(e.keyCode == 67){
        pressed["copy"] = false;
    }
    else if(e.keyCode == 86){
        pressed["paste"] = false;
    }
}
function get_selection(){
    rows = grid.getSelectedRows().sort(lowest_first);
    
    selection = "";
    for(key in rows){
        row = rows[key];
        item = data[row];
        selection += item.room + "\t" + item.capacity + "\n";
    }
    clipboard = $("textarea#clipboard")[0];
    clipboard.value = selection;
    clipboard.select();
    grid.select();
}
function lowest_first(a,b){
    return a-b;
}

