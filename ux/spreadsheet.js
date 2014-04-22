function spreadsheet(resource){
    this._grid = null;
    this._data_view = null;
    this._resource = resource;
    this.held = Array;
    this.clipboard;
    this.column_filters = {};
    this.save_changes_warning = false;
};

spreadsheet.prototype.options = {
    editable: true,
    enableCellNavigation: true,
    enableColumnReorder: false,
    autoEdit: false,
    enableAddRow: true,
    forceFitColumns: true,
    showHeaderRow: true,
    explicitInitialization: true,
};

spreadsheet.prototype.initialise = function(){
    this.setup_dataview();
    this.setup_grid();
    this.setup_clipboard();
    $(this._grid.getHeaderRow()).delegate(":input", "change keyup"
                                , html_helpers.get_filter_capture_function(this));
    this._grid.onHeaderRowCellRendered.subscribe(slickgrid.append_input_fields);
    this._grid.init();
    this.setup_dataview_subscriptions();
    this._resource.populate();
    html_helpers.setup_save_changes_warning(this);
    this.setup_persistence_button_listeners();
}

spreadsheet.prototype.setup_dataview = function(){
    this._data_view = new Slick.Data.DataView();
    this._data_view.setFilter(html_helpers.filter(this));
    this._data_view.setItems(this._resource.data);
    this._data_view._spreadsheet = this;
    this._data_view.refresh_grid = DataView.refresh_grid;
    this._resource._data_view = this._data_view;
}

spreadsheet.prototype.setup_grid = function(){
    var columns = this._resource.get_columns();
	this._grid = new Slick.Grid("#entry", this._data_view, columns, this.options);
    var spreadsheet_ref = this;
    this._grid._spreadsheet = spreadsheet_ref;
    this._resource._spreadsheet = spreadsheet_ref;
    this._grid.setSelectionModel(new Slick.RowSelectionModel());
    this._grid.onAddNewRow.subscribe(slickgrid.add_row);
    this._grid.onKeyDown.subscribe(html_helpers.key_down(this));
    this._grid.onKeyUp.subscribe(html_helpers.key_up(this));
    this._grid.onCellChange.subscribe(slickgrid.cell_changed);
}

spreadsheet.prototype.setup_persistence_button_listeners = function(){
    $(".save").bind("click",html_helpers.save(this));
    $(".discard").bind("click",html_helpers.discard(this));
}

spreadsheet.prototype.setup_clipboard = function(){
    this.clipboard = $("#clipboard");
    this.clipboard.bind("keyup",html_helpers.key_up(this));
    this.clipboard.bind("keydown",html_helpers.key_down(this));
    this.clipboard.bind("cut",html_helpers.cut(this));
    this.clipboard.bind("paste",html_helpers.delayed_paste(this));
    this.clipboard.bind("copy",html_helpers.get_copy_function(this));
}

spreadsheet.prototype.setup_dataview_subscriptions = function(){
    this._data_view.onRowsChanged.subscribe(this._data_view.refresh_grid);
    this._data_view.onRowCountChanged.subscribe(this._data_view.refresh_grid);
}

spreadsheet.prototype.get_column_by_name = function(column_name){
    var columns = this._grid.getColumns();
    var index = this._grid.getColumnIndex(column_name);
    return columns[index];
}

spreadsheet.prototype.valid_column_name_and_entry = function(column_name){
    return column_name !== undefined && this.column_filters[column_name] !== "";
}

spreadsheet.prototype.get_selection = function(){
    var rows = this.get_selected_rows();
    var selection = "";
    for(var key in rows){
        var row = rows[key];
        var item = this._data_view.getItem(row);
        selection += this._resource.item_to_string(item);
    }
    return selection;
}

spreadsheet.prototype.delete_selection = function(){
    var rows = this.get_selected_rows();
    this._data_view.beginUpdate();
    for(var key in rows){
        var row_num = rows[key];
        var item = this._data_view.getItem(row_num);
        if(typeof item != "undefined") this._data_view.deleteItem(item.id);
    }
    this._data_view.endUpdate();
    this._data_view.refresh_grid();
    this.save_changes_warning = true;
}

spreadsheet.prototype.get_selected_rows = function(){
    return this._grid.getSelectedRows().sort(html_helpers.lowest_first);   
}

spreadsheet.prototype.not_defined = function(thingy){
    return (typeof thingy === "undefined" || thingy == null);
}

spreadsheet.prototype.remove_dummies = function(){
    var items = this._data_view.getItems();
    for(i = 0; i< items.length; i++){
        var item = items[i];
        if(this._resource.is_dummy(item)){
            this._data_view.deleteItem(item.id);
        }
    }
}

spreadsheet.prototype.editor_inactive = function(){
    return this._grid.getCellEditor() == null;
}

spreadsheet.prototype.item_field_to_array = function(items, field){
    var return_array = [];
    for(var i in items){
        var item = items[i];
        return_array.push(item[field]);
    }
    return return_array;
}

spreadsheet.prototype.get_next_id = function(){
    var items = this._data_view.getItems();
    var ids = items.map(this.get_item_id);
    var max = Math.max.apply(null, ids);
    if(max == -Infinity) return 0;
    else return max + 1;
}

spreadsheet.prototype.get_item_id = function(item){
    return item.id;
}

spreadsheet.prototype.set_dummy_item = function(item){
    this._resource.set_item(item, this._resource.dummy_item());
}

spreadsheet.prototype.empty_data_view = function(){
    this._data_view.setItems([]);
}

spreadsheet.prototype.clean_xml = function(xml){
        xml = xml.replace(/&/g,"&amp;");
        xml = xml.replace(/,/g,"&#44;");
        return xml;
}

spreadsheet.prototype.validate_xml = function(xml){
    var success = true;
    try{
        $.parseXML(xml);
    }
    catch (error_string){
        alert("Invalid Input Entered!! See console log for details!");
        console.log(error_string);
        success = false;
    }
    return success;
}
