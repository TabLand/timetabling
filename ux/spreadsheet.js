var grid;
var held = Array;
var clipboard;

function formatter(row, cell, value, columnDef, dataContext) {
    return value;
}

var options = {
    editable: true,
    enableCellNavigation: true,
    enableColumnReorder: false,
    autoEdit: false,
    enableAddRow: true,
    forceFitColumns: true
};

function initialise_grid(){
    var columns = get_columns();
	grid = new Slick.Grid("#entry", data, columns, options);
    grid.setSelectionModel(new Slick.RowSelectionModel());
    grid.onAddNewRow.subscribe(add_row);
    grid.onKeyDown.subscribe(key_down);
    grid.onKeyUp.subscribe(key_up);
    clipboard = $("#clipboard");
    clipboard.bind("keyup",key_up);
    clipboard.bind("keydown",key_down);
    clipboard.bind("cut",cut);
    clipboard.bind("paste",delayed_paste);
    clipboard.bind("copy",copy);
    grid.onCellChange.subscribe(refresh_grid);
}

function add_row(e,args){
    var row = item_to_row(args);
    data.push(row);
    refresh_grid();
}

function key_down(e,args){
    var ctrl_pressed = e.keyCode == 17;
    var del_pressed = e.keyCode == 46;
    var backspace_pressed = e.keyCode == 8;
    var alpha_symbolic_numeric = e.keyCode >= 48;
    if(ctrl_pressed){ 
        clipboard.select();
        held["ctrl"] = true;
    }
    else if(!held["del"] && del_pressed && editor_inactive()){
        held["del"] = true;
        clear_selection();
    }
    else if(backspace_pressed){
        if(editor_inactive()) grid.editActiveCell();
    }
    else if(alpha_symbolic_numeric && !held["ctrl"]){
        if(editor_inactive()) grid.editActiveCell();
    }
}

function key_up(e,args){
    var ctrl_lifted = e.keyCode == 17;
    var del_lifted = e.keyCode == 46;

    if(ctrl_lifted){
        grid.getActiveCellNode().click();
        held["ctrl"] = false;
    }
    else if(del_lifted){
        held["del"] = false;
    }
}

function get_selection(){
    var rows = get_selected_rows();
    var selection = "";
    for(var key in rows){
        var row = rows[key];
        var item = data[row];
        selection += item_to_string(item);
    }
    return selection;
}

function lowest_first(a,b){
    return a-b;
}

function copy(){
    var copied_text = get_selection();
    clipboard.val(copied_text);
    clipboard.select();
}

function cut(){
    copy();
    clear_selection();
}

function clear_selection(){
    var rows = get_selected_rows();
    for(var key in rows){
        var row = rows[key];
        data[row] = dummy_item();
    }
    refresh_grid();
}

function get_selected_rows(){
    return grid.getSelectedRows().sort(lowest_first);   
}

function paste(){
    var pasted_text = clipboard.val();
    var pasted_rows = pasted_text.split("\n");
    var active_row = grid.getActiveCell().row;
    for(var i in pasted_rows){
        var pasted_row = pasted_rows[i];
        var pasted_cells = pasted_row.split("\t");
        var overwritten_row = active_row + parseInt(i);
        var existing_row = data[overwritten_row];
        var pasted_item = create_item(pasted_cells, existing_row);
        data[overwritten_row] = pasted_item;
    }
    refresh_grid();
}

function delayed_paste(){
    setTimeout(paste,1);
}

function not_defined(thingy){
    return (typeof thingy === "undefined");
}

function refresh_grid(){
    var reselect_trigger = remove_dummies();
    grid.updateRowCount();
    grid.invalidate();
    grid.render();
    if(reselect_trigger) grid.editActiveCell();
}

function remove_dummies(){
    var size = data.length;
    for(i=0; i<size; i++){
        while(is_dummy(data[i])){
            data.splice(i,1);
            size--;
            var next_loop_out_of_bounds = i>=size;
            if(next_loop_out_of_bounds) break;
        }
    }
    return reselect_drowned_row(size);
}

function reselect_drowned_row(size){
    var cell = grid.getActiveCell();
    if(cell.row > size){
        grid.setActiveCell(size,0);
        return true;
    }
    else return false;
}

function editor_inactive(){
    return grid.getCellEditor() == null;
}
