function initialise_sliders(){
	$( "div.slider" ).slider({
		slide: slid,
		step: 0.000000001,
        change: changed
	});
    populate();
};

function slid(event, ui){
    update_indicator(event.target.id, ui.value);
}

function update_indicator(slider_id, penalty){
	var indicator_id = "#" + slider_id + "Penalty";
	$(indicator_id).text(penalty);
}

function changed(event, ui){
    var new_constraint = {"type":event.target.id,"penalty":ui.value};
    //old constraint value not important - ignored in DB, but stub inserted for consistency with db/ResourceUpdater.pm

    var change              = {"type":"edition", "old":"stub", "new":new_constraint};
    var changes             = [change];
    var stringified_changes = JSON.stringify(changes);

    $.post( "../db/ConstraintUpdater.pl",{"changes": stringified_changes});
}

function populate(){
    $.get("../db/ConstraintList.pl", get_process_input);
}

function get_process_input(constraints_list){
    for(i=0; i<constraints_list.length; i++){
        var constraint = constraints_list[i];
        var slider_id  = constraint.type;
        var penalty    = constraint.penalty;
        $("#" + slider_id).slider("value",penalty);
        update_indicator(slider_id, penalty);
    }
}
