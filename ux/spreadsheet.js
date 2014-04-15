var grid;

function formatter(row, cell, value, columnDef, dataContext) {
    return value;
}

var options = {
    editable: true,
    enableCellNavigation: true,
    enableColumnReorder: false,
    autoEdit: true
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

    this.handleGridClick = function(e, args) {
        var cell = self._grid.getCellFromEvent(e);
        if (!cell || !self._grid.canCellBeSelected(cell.row, cell.cell)) {
            return;
        }
        self.onSelectedRangesChanged.notify([new Slick.Range(cell.row, cell.cell, cell.row, cell.cell)]);
    };

    this.handleKeyPress = function(e, args){
    	if(e.keyCode == 38) console.log("up");
    	else if(e.keyCode == 37) console.log("left");
    	else if(e.keyCode == 39) console.log("right");
    	else if(e.keyCode == 40) console.log("down");
    	console.log(args);
    	var cell = self._grid.getCellFromEvent(e);
    	console.log(cell);
        self.handleGridClick(e,args);
    }
}
