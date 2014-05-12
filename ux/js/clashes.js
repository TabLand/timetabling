function init(){
    update_clashes();
}

function update_clashes(){ 

    $.get("../db/FetchClashesInfo.pl",list_all_clashes);
    setTimeout(update_clashes, 100);
}

function list_all_clashes(clashes){
    clashes_text = "";
    for(i = 0; i<clashes.length; i++){
        var clash = clashes[i];
        if     (clash.ClashType == "RoomClash")   append_room_clash(clash);
        else if(clash.ClashType == "PersonClash") append_person_clash(clash);
        else if(clash.ClashType == "LunchClash")  append_lunch_clash(clash);
        else if(clash.ClashType == "RoomOverCap") append_room_over_capacity(clash);
    }
    $("#clashes_list").html(clashes_text);
}

function append_room_clash(clash){
    var text = "Room " + highlight(clash.RoomCode) + " Double Booked " + get_activity_text(clash);
    append(text);
}

function append_person_clash(clash){
    var text = "User " + highlight(clash.Username) + " Double Booked " + get_activity_text(clash);
    append(text);
}

function append_lunch_clash(clash){
    var text = "User " + highlight(clash.Username) + " partially or fully missing out on lunch on " 
               + highlight(clash.Day);
    append(text);
}

function append_room_over_capacity(clash){
    var text = "Room " + highlight(clash.RoomCode) + " is Over Capacity " + get_activity_text(clash)
               + ". Capacity Needed is " + highlight(clash.CapacityNeeded) + " but total capacity is only " 
               + highlight(clash.Capacity);
    append(text);
}

function get_activity_text(clash){
    var text = "from " + highlight(clash.Start) + " till " + highlight(clash.Finish) + " for activity (" +
               highlight(clash.Type) + "," + highlight(clash.Code) + "," + highlight(clash.Name) + ")";
    return text;
}

function highlight(text){
    return '<span class="important">' + text + '</span>';
}

function append(text){
    clashes_text += text + "<br/>";
}
