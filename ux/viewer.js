function viewer(){
    this.data = [];
    this._data_view = null;
    this._spreadsheet = null;
}

viewer.prototype.get_columns = function(){
	return [{id: "code", name: "Resource Code", field: "code" , editor: Slick.Editors.Text},
            {id: "type", name: "Resource Type", field: "type" , editor: Slick.Editors.Text}];
}

viewer.prototype.check_duplicate_primary_keys = function(viewer){
    //stub
}

viewer.prototype.validate_all_items = function(){
    //stub
}

viewer.prototype.item_to_string = function(item){
    //stub
}

viewer.prototype.clone = function(item){
    //stub
}

viewer.prototype.equals = function(first, second){
    //stub
}

viewer.prototype.create_item = function(item, existing_item){
    if(this._spreadsheet.not_defined(existing_item)) existing_item = this.dummy_item();
    var id = this._spreadsheet.get_next_id();
    var code = item[0] || existing_item.code;
    var type = item[1] || existing_item.type;
    return {"id": id, "code": code, "type": type};
}

viewer.prototype.dummy_item = function(){
    return {id: 0, code: "", type: ""};
}

viewer.prototype.set_item = function(item, new_item){
    //stub
}

viewer.prototype.is_dummy = function(item){
    //stub
}

viewer.prototype.item_to_row = function(args){
    var new_id = args.item.id || this._spreadsheet.get_next_id();
    var new_code = args.item.code || "";
    var new_type = args.item.type || "";
    return {id: new_id, code: new_code, type: new_type};
}

viewer.prototype.populate = function(){
    this._spreadsheet._grid.onActiveCellChanged.subscribe(viewer_selection_changed(this));
    initialise_tooltips();
    this._spreadsheet.empty_data_view();
    $.get("../db/PersonList.pl", this.fill_persons(this));
    $.get("../db/RoomList.pl", this.fill_rooms(this));
}

viewer.prototype.fill_persons = function(viewer_ref){
    return function(data){
        var people_list = data;
        viewer_ref._data_view.beginUpdate();

        for(var i=0; i < people_list.length; i++){
            var person = people_list[i];
            var person_item = viewer_ref.create_item([person.username,person.type],null);
            viewer_ref._data_view.addItem(person_item);
        }

        viewer_ref._data_view.endUpdate();
        viewer_ref._data_view.refresh_grid();
    }
}

viewer.prototype.fill_rooms = function(viewer_ref){
    return function(data){
        var rooms_list = data;
        viewer_ref._data_view.beginUpdate();

        for(var i=0; i < rooms_list.length; i++){
            var room = rooms_list[i];
            var room_item = viewer_ref.create_item([room.code,"Room"],null);
            viewer_ref._data_view.addItem(room_item);
        }

        viewer_ref._data_view.endUpdate();
        viewer_ref._data_view.refresh_grid();
    }
}

viewer.prototype.save_all = function(json){
    //stub
}

viewer_spreadsheet = new spreadsheet(new viewer());
viewer_spreadsheet.options.editable = false;

function viewer_selection_changed(viewer_ref){
    return function(event, args){
        var resource_index = args.row;
        var resource = viewer_ref._data_view.getItem(resource_index);
        var resource_stringified = JSON.stringify(resource);
        $.post("../db/FetchSchedule.pl",{"view_request": resource_stringified}, display_on_calendar);
    }
}

function display_on_calendar(bookings){
    clear_all_bookings();
    var bookings_temp = get_empty_bookings_temp();

    for(var i=0; i<bookings.length; i++){
        var booking = bookings[i];
        bookings_temp[booking.DayID].push(booking);
    }

    for(var i=0; i<7; i++){
        var day_bookings = bookings_temp[i];
        day_bookings.sort(booking_sort_func);

        for(var j = 0; j < day_bookings.length; j++){
            var booking = day_bookings[j];
            var booking_text = '<span class="booking_text">' + get_booking_description(booking) +'</span>';
            var floater = '<div class="floater"></div>';
            var booking_info = get_booking_detailed_info(booking);
            var booking_tag = $('<span class="booking" title="'+booking_info+'">'+floater+booking_text+'</span>');
            booking_tag.appendTo("#"+booking.Day);

            var previous_heights = sum_previous_heights(day_bookings, j);
            console.log(j + " PRev heights " + previous_heights);
            var top    = booking.Start/0.24 - previous_heights;
            var height = booking.Duration/0.24;
            $(booking_tag).css("top", top + "%");
            $(booking_tag).css("height", height + "%");
        }
    }
}

function clear_all_bookings(){
    var bookings = $("span.booking");
    bookings.remove();
}

function get_booking_description(booking){
    if(booking.Type=="Lunch") return get_lunch_description(booking);
    else return get_activity_description(booking);
}

function get_booking_detailed_info(booking){
    if(booking.Type=="Lunch"){
        return "Lunch starts at " + booking.Start + " and " 
                + "| finshes at " + (parseFloat(booking.Start)+1)
                + "| Revision: " + booking.RevisionID;
    }
    else{
        return "Module Code: " + booking.Code
              +"|Module Name: " + booking.Name
              +"|Activity Type: " + booking.Type
              +"|Activity Group: " + booking.ActivityGroup
              +"|Room: " + booking.RoomCode
              +"|Start: " + booking.Start
              +"|Finish: " + booking.Finish
              +"|Revision: " + booking.RevisionID;
    }
}

function get_lunch_description(booking){
    return "Lunch-" + booking.Start;
}

function get_activity_description(booking){
    return booking.Type + "-" + booking.Start;
}

function get_empty_bookings_temp(){
    var bookings = Array();
    for(var i=0; i<7; i++){
        bookings[i] = Array();
    }
    return bookings;
}

function booking_sort_func(a, b){
    return parseFloat(a.Start) - parseFloat(b.Start);
}

function sum_previous_heights(day_booking, j){
    if(j>0){
        var sum_heights = 0;
        for(var i=0; i<j; i++){
            sum_heights += parseFloat(day_booking[i].Duration);
        }
        return sum_heights / 0.24;
    }
    else {
        return 0;
    }
}

function initialise_tooltips(){
$(document).tooltip({

});
    $(function() {
        $( document ).tooltip({
            position: {
                my: "center bottom-20",
                at: "center top",
                using: function( position, feedback ) {
                    $( this ).css( position );
                    $( "<div>" )
                        .addClass( "arrow" )
                        .addClass( feedback.vertical )
                        .addClass( feedback.horizontal )
                        .appendTo( this );
                }
            },
            hide: { 
                effect: "explode",
                delay: 20
            },
//http://stackoverflow.com/questions/14599562/jquery-tooltip-add-line-break
            content: function () {
                return ( ( $( this ).prop( 'title' ).replace(/\|/g, '<br />' )));
            }
        });
     });
}
