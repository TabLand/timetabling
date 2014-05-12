revisions = Array();
function init(){
    initialise_bar_chart();
    $("#reinitialize").bind("click", reinitialize);
    $("#schedule").bind("click", schedule);
    update_revisions();
}

function reinitialize(){
    $.get("../db/SchedulerInit.pl", debug_to_log);
}

function schedule(){
    $.get("../db/Scheduler.pl", debug_to_log);
}

function debug_to_log(data){
    //console.log(data);
}

function get_penalties(){
    $.get("../db/FetchPenalties.pl", update_revisions);
}

function update_revisions(revision_penalties){
    //might need to loop here to update newer revisions;
    if(typeof revision_penalties == "undefined") revision_penalties = Array();
    console.log(revision_penalties);
    revisions = revisions_to_array(revision_penalties);
    bind_revisions(revisions);
    interval_handle = setTimeout(get_penalties, 100);
}

function stop_refresh(){
    clearInterval(interval_handle);
}

//http://stackoverflow.com/questions/12717652/making-an-arc-in-d3-js
//http://jsfiddle.net/D5k8x/ @Duopixel
function initialise_bar_chart(){
    vis = d3.select("#curved_bar_chart").append("svg");
}

function revisions_to_array(revision_penalties){
    for(i=0; i<revision_penalties.length; i++){
        revisions[i] = parseFloat(revision_penalties[i].SumPenalties);
    }
    revisions.splice(i,revisions.length-i);
    return revisions;
}

function bind_revisions(revisions){
    var max_radius   = 150;
    var max_revision = revisions.length;
    vis.selectAll("path").remove();
    var bars = vis.selectAll("path").data(revisions);
        bars.enter()
            .append("path")
            .attr("d", function(revision,i){
                            return get_arc(revision,i)();
                        })
            .attr("transform", "translate("+max_radius+","+max_radius+")")
            .attr("stroke", "white")
            .attr("stroke-width", 10/max_revision)
            .attr("fill", "red")
            .append("svg:title")
            .text(function(revision, i){
                        return get_revision_info(revision,i);
                    });
}

function get_arc(revision, revision_id){
    var pi = Math.PI;
    var max_radius = 150;
    var min_radius = 75;

    var max_revision         = revisions.length;
    var max_penalty          = Math.max.apply(Math,revisions);
    var revision_height_diff = (max_radius - min_radius) / max_revision;
    var height_multiplier    = max_revision - revision_id;
    var inner_radius         = min_radius + revision_height_diff * height_multiplier;
    var outer_radius         = min_radius + revision_height_diff * (height_multiplier -1);
    
    var min_angle            = 15;
    var max_angle            = 345;
    var angle_range          = max_angle - min_angle;

    var start_angle          = 0;
    if(max_penalty==0) max_penalty = 1;
    var end_angle_proportion = revision / max_penalty;
    var end_angle            = min_angle + (angle_range * end_angle_proportion);
    
    var arc = d3.svg.arc()
                    .innerRadius(inner_radius)
                    .outerRadius(outer_radius)
                    .startAngle(start_angle * (pi/180))
                    .endAngle(end_angle * (pi/180)); 
    return arc;
}

function get_revision_info(revision, revision_id){
    return "RevisionID: "     + (revision_id+1)
          +"\nSumPenalties: " + revision;
}

function loopy(i){
    var myrevpen = Array();
    for(j =0; j<i; j++){
        myrevpen.push(j);
    }
    return myrevpen;
}

function animate(i){
    stop_refresh();
    revisions = loopy(i);
    bind_revisions(revisions);
    setTimeout(function(){animate(i*2)}, 500);
}
