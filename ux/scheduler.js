function init(){
    get_penalties();
    $("#reinitialize").bind("click", reinitialize);
    $("#schedule").bind("click", schedule);
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
    $.get("../db/FetchPenalties.pl", display_revisions);
}

function display_revisions(revision_penalties){
    initialise_bar_chart();
    var max_revision = get_max_revision(revision_penalties);
    var max_penalty  = get_max_penalty(revision_penalties);

    for(var i = 0; i<revision_penalties.length; i++){
        var revision_penalty = revision_penalties[i];

        add_revision(revision_penalty, max_revision, max_penalty);
    }
    setTimeout(get_penalties, 100);
}

//http://stackoverflow.com/questions/12717652/making-an-arc-in-d3-js
//http://jsfiddle.net/D5k8x/ @Duopixel
function initialise_bar_chart(){
    var chart = d3.select("svg");
    chart.remove();
    vis = d3.select("#curved_bar_chart").append("svg");
}

pi = Math.PI;

function add_revision(revision, max_revision, max_penalty){
    var min_radius           = 75;
    var max_radius           = 150;
    var revision_height_diff = (max_radius - min_radius) / max_revision;
    var height_multiplier    = max_revision - parseInt(revision.RevisionID);
    var inner_radius         = min_radius + revision_height_diff * height_multiplier;
    var outer_radius         = min_radius + revision_height_diff * (height_multiplier -1);
    
    var min_angle            = 15;
    var max_angle            = 345;
    var angle_range          = max_angle - min_angle;

    var start_angle          = 0;
    if(max_penalty==0) max_penalty = 1;
    var end_angle_proportion = parseFloat(revision.SumPenalties) / max_penalty;
    var end_angle            = min_angle + (angle_range * end_angle_proportion);
    
    var arc = d3.svg.arc()
                    .innerRadius(inner_radius)
                    .outerRadius(outer_radius)
                    .startAngle(start_angle * (pi/180))
                    .endAngle(end_angle * (pi/180));
    var middle_x = window.innerWidth / 2;
    var middle_y = window.innerHeight / 2;
    vis.append("path")
        .attr("d", arc)
        .attr("transform", "translate("+max_radius+","+max_radius+")")
        .attr("stroke", "white")
        .attr("stroke-width", 10/max_revision)
        .attr("fill", "red")
        .append("svg:title")
        .text(function(d, i) { return "RevisionID: " + revision.RevisionID + 
                                      "\nSumPenalties: " + revision.SumPenalties});;
}

function get_max_revision(revision_penalties){
    var revisions = Array();
    for(i =0; i<revision_penalties.length; i++){
        var revision_id = parseInt(revision_penalties[i].RevisionID);
        revisions.push(revision_id);
    }
    return Math.max.apply(Math, revisions);
}

function get_max_penalty(revision_penalties){
    var penalties = Array();
    for(i =0; i<revision_penalties.length; i++){
        var penalty = parseFloat(revision_penalties[i].SumPenalties);
        penalties.push(penalty);
    }
    return Math.max.apply(Math, penalties);
}

function loopy(i){
    var myrevpen = Array();
    for(j =0; j<i; j++){
        myrevpen.push({"RevisionID":j, "SumPenalties": (i-j)*100});
    }
    return myrevpen;
}

function animate(i){
    display_revisions(loopy(i));
    setTimeout(function(){animate(i+1)}, 1);
}
