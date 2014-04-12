function initialise_sliders(){
	$( "div.slider" ).slider({
		slide: function( event, ui ) {
			var indicator_id = "#" + event.target.id + "_penalty";
			$(indicator_id).text(ui.value);
		},
		step: 0.000000001
	});
};

