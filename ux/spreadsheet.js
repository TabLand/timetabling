var grid;
var held = Array;
var clipboard;
var data_view;
var column_filters = {};

function formatter(row, cell, value, columnDef, dataContext) {
    return value;
}

var options = {
    editable: true,
    enableCellNavigation: true,
    enableColumnReorder: false,
    autoEdit: false,
    enableAddRow: true,
    forceFitColumns: true,
    showHeaderRow: true,
    explicitInitialization: true,
};

function initialise_grid(){
    setup_dataview();
    setup_grid();
    setup_clipboard();
    $(grid.getHeaderRow()).delegate(":input", "change keyup", capture_filter_entries);
    grid.onHeaderRowCellRendered.subscribe(append_input_fields);
    grid.init();
    setup_dataview_subscriptions();
    populate();
}

function append_input_fields(e,args){
    var header_cell = $(args.node);
    header_cell.empty;
    var input = $("<input type='text' class='column-filter' placeholder='Search...'>");
    input.data("columnId", args.column.id);
    input.val(column_filters[args.column.id])
    input.appendTo(header_cell);
}

function capture_filter_entries(e) {
    var columnId = $(this).data("columnId");
    if (columnId != null) {
        column_filters[columnId] = $.trim($(this).val());
        data_view.refresh();
    }
}

function setup_clipboard(){
    clipboard = $("#clipboard");
    clipboard.bind("keyup",key_up);
    clipboard.bind("keydown",key_down);
    clipboard.bind("cut",cut);
    clipboard.bind("paste",delayed_paste);
    clipboard.bind("copy",copy);
}

function setup_grid(){
    var columns = get_columns();
	grid = new Slick.Grid("#entry", data_view, columns, options);
    grid.setSelectionModel(new Slick.RowSelectionModel());
    grid.onAddNewRow.subscribe(add_row);
    grid.onKeyDown.subscribe(key_down);
    grid.onKeyUp.subscribe(key_up);
    grid.onCellChange.subscribe(refresh_grid);
}

function setup_dataview(){
    data_view = new Slick.Data.DataView();
    data_view.setFilter(filter);
    data_view.setItems(data);
}

function setup_dataview_subscriptions(){
    data_view.onRowsChanged.subscribe(refresh_grid);
    data_view.onRowCountChanged.subscribe(refresh_grid);
}

function filter(item){
    all_match = true;
    for(var column_name in column_filters){
        if(valid_column_name_and_entry(column_name)){
            var column = get_column_by_name(column_name);
            var cell_entry = item[column.field];
            var filter_entry = column_filters[column_name];
            var match = new RegExp(filter_entry,"i");
            all_match = all_match && match.test(cell_entry);
        }
    }
    return all_match;
}

function get_column_by_name(column_name){
    var columns = grid.getColumns();
    var index = grid.getColumnIndex(column_name);
    return columns[index];
}

function valid_column_name_and_entry(column_name){
    return column_name !== undefined && column_filters[column_name] !== "";
}

function add_row(e,args){
    var row = item_to_row(args);
    data_view.addItem(row);
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
    data_view.beginUpdate();
    for(var key in rows){
        var row_num = rows[key];
        var item = data_view.getItem(row_num);
        set_dummy_item(item);
    }
    data_view.endUpdate();
    refresh_grid();
}

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
    data_view.beginUpdate();
    for(var i in pasted_rows){
        var pasted_row = pasted_rows[i];
        var pasted_cells = pasted_row.split("\t");
        var overwritten_row = active_row + parseInt(i);
        var existing_item = data_view.getItem(overwritten_row);
        var pasted_item = create_item(pasted_cells, existing_item);

        if(existing_item == null) data_view.addItem(pasted_item);
        else set_item(existing_item, pasted_item);
    }
    data_view.endUpdate();
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
    data_view.refresh();
}

function remove_dummies(){
    var items = data_view.getItems();
    for(i = 0; i< items.length; i++){
        var item = items[i];
        if(is_dummy(item)){
            data_view.deleteItem(item.id);
        }
    }
}

function reselect_drowned_row(size){
    var cell = grid.getActiveCell() || {row:0,cell:0};
    if(cell.row > size){
        grid.setActiveCell(size,0);
        return true;
    }
    else return false;
}

function editor_inactive(){
    return grid.getCellEditor() == null;
}

function item_field_to_array(items, field){
    var return_array = [];
    for(var i in items){
        var item = items[i];
        return_array.push(item[field]);
    }
    return return_array;
}
