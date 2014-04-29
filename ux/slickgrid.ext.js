function slickgrid(){};

slickgrid.before_cell_edited = function(e,args){
    this._spreadsheet._old_resource = this._spreadsheet._resource.clone(args.item);
}

slickgrid.cell_changed = function(e,args){
    if(html_helpers.validate_items_and_keys(this._spreadsheet._resource)){
        var new_resource = this._spreadsheet._resource.clone(args.item);
        var old_resource = this._spreadsheet._old_resource;
        this._spreadsheet._data_view.refresh_grid();
        this._spreadsheet.edition(old_resource, new_resource);
    }
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
    if(html_helpers.validate_items_and_keys(this._spreadsheet._resource)){
        var row = this._spreadsheet._resource.item_to_row(args);
        this._spreadsheet._data_view.addItem(row);
        this._spreadsheet._data_view.refresh_grid();
        this._spreadsheet.addition(this._spreadsheet._resource.clone(row));
    }
}

DataView.refresh_grid = function(){
    var reselect_trigger = this._spreadsheet.remove_dummies();
    this._spreadsheet._grid.updateRowCount();
    this._spreadsheet._grid.invalidate();
    this._spreadsheet._grid.render();
    if(reselect_trigger) this._spreadsheet._grid.editActiveCell();
    this.refresh();
}

DataView.activate_cell_by_id = function(id){
    var row = this.getIdxById(id);
    var cell = this._spreadsheet._grid.getActiveCell().cell;
    this._spreadsheet._grid.setActiveCell(row,cell);
}
