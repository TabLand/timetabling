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
	grid.setSelectionModel(new SingleCellSelectionModel());
}

function get_columns(){
	return [{id: "room", name: "Room", field: "room" , editor: Slick.Editors.Text, width: 250},
		{id: "capacity", name: "Capacity", field: "capacity", editor: Slick.Editors.Integer , width: 250}];
}

function add_new_row(){
    row = {room: "", capacity: ""};
    data.push(row);
    grid.render();
}

function SingleCellSelectionModel() {
    var self = this;

    this.init = function(grid) {
    self._grid = grid;
    self._grid.onClick.subscribe(self.handleGridClick);
      	self._grid.onKeyDown.subscribe(self.handleKeyPress);
    };

    this.destroy = function() {
        self._grid.onClick.unsubscribe(self.handleGridClick);
    };

    this.onSelectedRangesChanged = new Slick.Event();

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
