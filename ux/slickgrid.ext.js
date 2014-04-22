function slickgrid(){};

slickgrid.cell_changed = function(){
    this._spreadsheet.save_changes_warning = true;
    this._spreadsheet._data_view.refresh_grid();
}

slickgrid.append_input_fields = function(e,args){
    var header_cell = $(args.node);
    header_cell.empty();
    var input = $("<input type='text' class='column-filter' placeholder='Search...'>");
    input.data("columnId", args.column.id);
    input.val(this._spreadsheet.column_filters[args.column.id])
    input.appendTo(header_cell);
}

slickgrid.add_row = function(e,args){
    var row = this._spreadsheet._resource.item_to_row(args);
    this._spreadsheet._data_view.addItem(row);
    this._spreadsheet._data_view.refresh_grid();
    this._spreadsheet.save_changes_warning = true;
}

DataView.refresh_grid = function(){
    var reselect_trigger = this._spreadsheet.remove_dummies();
    this._spreadsheet._grid.updateRowCount();
    this._spreadsheet._grid.invalidate();
    this._spreadsheet._grid.render();
    if(reselect_trigger) this._spreadsheet._grid.editActiveCell();
    this.refresh();
}
