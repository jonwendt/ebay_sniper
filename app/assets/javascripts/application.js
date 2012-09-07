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



$(document).ready(function() {
  $('#ebay-pic').css('marginTop', $('#ebay-pic').parent().height() / 2 - $('#ebay-pic').height() / 2);

  // Not being called after the AJAX sorting is done.
  // $('.check-all').click(function(event) {
  //   event.stopPropagation(); // Prevent link from following through to its given href
  //   // If the amount of checked checkboxes does not equal the amount of checkboxes, then check all of them. Otherwise, uncheck all.
  //   if ($('[type="checkbox"]').length != $('input:checked').length) {
  //     $('[type="checkbox"]').prop('checked', true);
  //   }
  //   else {
  //     $('[type="checkbox"]').prop('checked', false);
  //   }
  // });
});


/* Custom way to update page */
// $(document).ready(function() {
	// $("#new_auction").submit(function() {
	// 	$.ajax({ url: "/auctions.json", dataType: "json", type: "POST", data: $(this).serialize(), 
	// 		success: function(data) {
				
	// 			message = "<h2>" + $(data).size() + " " + ($(data).size() != 1 ? "errors" : "error") + " prohibited this auction from being saved:</h2><ul>";
				
	// 			list = $("<ul></ul>");
				
	// 			$(data).each(function(index) {
	// 				list.append("<li>" + this + "</li>");
	// 			});
				
	// 			$("#error_explanation").html(message + list.html());
	// 			$("#error_explanation").show();
	// 		}
	// 	});
	// 	return false;
	// });
// });