function html_helpers(){};

html_helpers.save = function(spreadsheet_ref){
    return function(){
        if(spreadsheet_ref._changes.length == 0){
            alert("No changes to save!");
        }
        else if(confirm("Are you sure you wish to save changes?")){
            if(html_helpers.validate_items_and_keys(spreadsheet_ref._resource)){
                var json_out = spreadsheet_ref.get_stringified_changes();
                spreadsheet_ref._resource.save_all(json_out);
                spreadsheet_ref._changes = [];
            }
        }
    }
}

html_helpers.key_up = function(spreadsheet_ref){
    return function(e,args){
        var ctrl_lifted = e.keyCode == 17;
        var del_lifted = e.keyCode == 46;

        if(ctrl_lifted){
            spreadsheet_ref._grid.getActiveCellNode().click();
            spreadsheet_ref.held["ctrl"] = false;
        }
        else if(del_lifted){
            spreadsheet_ref.held["del"] = false;
        }
    }
}

html_helpers.key_down = function(spreadsheet_ref){
    return function(e,args){
        var ctrl_pressed = e.keyCode == 17;
        var del_pressed = e.keyCode == 46;
        var backspace_pressed = e.keyCode == 8;
        var alpha_symbolic_numeric = e.keyCode >= 48;
        var a_key_pressed = e.keyCode == "A".charCodeAt(0);

        if(ctrl_pressed){ 
            spreadsheet_ref.clipboard.select();
            spreadsheet_ref.held["ctrl"] = true;
        }
        else if(spreadsheet_ref.held["ctrl"] && a_key_pressed){
            var final_row = spreadsheet_ref._data_view.getLength();
            var all_rows = html_helpers.fill_consecutively(0,final_row);
            spreadsheet_ref._grid.setSelectedRows(all_rows);
        }
        else if(!spreadsheet_ref.held["del"] && del_pressed && spreadsheet_ref.editor_inactive()){
            spreadsheet_ref.held["del"] = true;
            spreadsheet_ref.delete_selection();
        }
        else if(backspace_pressed){
            if(spreadsheet_ref.editor_inactive()) spreadsheet_ref._grid.editActiveCell();
        }
        else if(alpha_symbolic_numeric && !spreadsheet_ref.held["ctrl"]){
            if(spreadsheet_ref.editor_inactive()){
                spreadsheet_ref._grid.editActiveCell();
            }
        }
    }
}

html_helpers.delayed_paste = function(spreadsheet_ref){
    return function(){
        setTimeout(html_helpers.paste(spreadsheet_ref),1);
    }
}

html_helpers.paste = function(spreadsheet_ref){
    return function(){
        var pasted_text = spreadsheet_ref.clipboard.val();
        spreadsheet_ref.clipboard.val("");
        var pasted_rows = pasted_text.split("\n");
        var active_row = spreadsheet_ref._grid.getActiveCell().row;
        var active_cell = spreadsheet_ref._grid.getActiveCell().cell;

        spreadsheet_ref._data_view.beginUpdate();

        for(var i in pasted_rows){
            var pasted_row = pasted_rows[i];
            var pasted_cells = pasted_row.split("\t");

            var overwritten_row = active_row + parseInt(i);
            var existing_item = spreadsheet_ref._data_view.getItem(overwritten_row);
            var pasted_item = spreadsheet_ref._resource.create_item(pasted_cells, existing_item);

            var old_row = spreadsheet_ref._resource.clone(existing_item);
            var new_row = spreadsheet_ref._resource.clone(pasted_item);
            var is_new_row_addition = existing_item == null;

            if(is_new_row_addition){
                spreadsheet_ref._data_view.addItem(pasted_item);
                spreadsheet_ref.addition(new_row);
            }
            else{ 
                spreadsheet_ref._resource.set_item(existing_item, pasted_item);
                spreadsheet_ref.edition(old_row, new_row);
            }
            spreadsheet_ref._grid.setActiveCell(overwritten_row, active_cell);
        }

        spreadsheet_ref._data_view.endUpdate();
        spreadsheet_ref._data_view.refresh_grid();
    }
}

html_helpers.get_filter_capture_function = function(spreadsheet_ref) {
    return function(){
        var columnId = $(this).data("columnId");
        if (columnId != null) {
            spreadsheet_ref.column_filters[columnId] = $.trim($(this).val());
            spreadsheet_ref._data_view.refresh();
        }
    }
}

html_helpers.get_copy_function = function(spreadsheet_ref){
    return function(){
        var copied_text = spreadsheet_ref.get_selection();
        spreadsheet_ref.clipboard.val(copied_text);
        spreadsheet_ref.clipboard.select();
    }
}

html_helpers.setup_save_changes_warning = function(spreadsheet_ref){
    window.onbeforeunload = function(e) {
        if(spreadsheet_ref._changes.length > 0){
            return 'Are you sure you want to leave this page?  You will lose any unsaved data.';
        }
        else return null;
    };
}

html_helpers.discard = function(spreadsheet_ref){
    return function(){
        if(spreadsheet_ref._changes == 0){
            alert("No changes to discard!");
        }
        else if(confirm("Are you sure you wish to discard changes?")){
            spreadsheet_ref._resource.populate();
            spreadsheet_ref._changes = [];
        }
    }
}

//for some unknown reason DataView calls this from the window perspective...
html_helpers.filter = function(spreadsheet_ref){
    return function(item){
        var all_match = true;
        for(var column_name in spreadsheet_ref.column_filters){
            if(spreadsheet_ref.valid_column_name_and_entry(column_name)){
                var column = spreadsheet_ref.get_column_by_name(column_name);
                var cell_entry = item[column.field];
                var filter_entry = spreadsheet_ref.column_filters[column_name];
                var match = new RegExp(filter_entry,"i");
                all_match = all_match && match.test(cell_entry);
            }
        }
        return all_match;
    }
}

html_helpers.lowest_first = function(a,b){
    return a-b;
}

html_helpers.cut = function(spreadsheet_ref){
    return function(){
        (html_helpers.get_copy_function(spreadsheet_ref))();
        spreadsheet_ref.delete_selection();
    }
}

html_helpers.get_xml_node_data = function(xml_node){
    if(xml_node.firstChild!=null) return xml_node.firstChild.data;
    else return "";
}

html_helpers.fill_consecutively = function(from, to){
    var array = Array();
    for(var i = from; i<to; i++){
        array.push(i);
    }
    return array;
}

html_helpers.check_duplicates = function(array){
    array.sort();
    if(array.length>=2){
        for(var i=0;i<array.length-1;i++){
            var first = array[i];
            var second = array[i+1];
            if(first==second) return {exist: true, culprit: first};
        }
        return {exist: false, culprit: null};
    }
    else return {exist: false, culprit: null};
}

html_helpers.validate_items_and_keys = function(resource_ref){
    var valid     = resource_ref.validate_all_items();
    var duplicate = resource_ref.check_duplicate_primary_keys();
    return valid && !duplicate;
}
