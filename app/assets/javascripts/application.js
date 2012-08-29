// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap
//. require_tree .

function deleteAuction(id) {
	$.ajax({url: "/auctions/" + id + ".json", type: "DELETE"}).done(function() { $("[auction-id='" + id +"']").parent().detach(); });
}

$(document).ready(function() {
	$('#ebay-pic').css('marginTop', $('#ebay-pic').parent().height() / 2 - $('#ebay-pic').height() / 2);
});


/* Custom way to update page */
// $(document).ready(function() {
// 	$("#new_auction").submit(function() {
// 		$.ajax({ url: "/auctions.json", dataType: "json", type: "POST", data: $(this).serialize(), 
// 			success: function(data) {
// 				
// 				message = "<h2>" + $(data).size() + " " + ($(data).size() != 1 ? "errors" : "error") + " prohibited this auction from being saved:</h2><ul>";
// 				
// 				list = $("<ul></ul>");
// 				
// 				$(data).each(function(index) {
// 					list.append("<li>" + this + "</li>");
// 				});
// 				
// 				$("#error_explanation").html(message + list.html());
// 				$("#error_explanation").show();
// 			}
// 		});
// 		return false;
// 	});
// });