$(document).ready(function() {
	var ua = navigator.userAgent.toLowerCase();
	if (ua.indexOf("mobile") == -1) {

		$( "li.awstoc.closed ul" ).hide();		
		
		var thispageTocEntry = $("li.awstoc a[href='" + thispage + "']");
		if (thispageTocEntry.length) {
			if (thispageTocEntry.position().top > $( "#divLeft" ).height()) {
				$( "#divLeft" ).scrollTop(thispageTocEntry.position().top-5);
			}
		}
		
		$( "li.awstoc" ).bind("click", function(event) {
			event.stopPropagation();

			if (event.target.nodeName == "LI") {
				if ($( event.target ).hasClass("closed") || $( event.target ).hasClass("opened")) {
					$( event.target ).toggleClass("closed opened");
					if ($( event.target ).hasClass("closed")) {
						$( event.target ).children("ul").hide();
					}
					if ($( event.target ).hasClass("opened")) {
						$( event.target ).children("ul").show();
					}
				}
			}
		});
		
		resizePanes();

		window.onresize = resizePanes;

		if (location.hash != null && location.hash.length > 0 && ua.indexOf("firefox") > 0) {
			location.hash = location.hash;
		}
	}
});

function resizePanes() {
	var windowHeight = $(window).height();
	var headerHeight = $( "#divHeader" ).height();
	var windowWidth = $(window).width();
	var leftWidth = $( "#divLeft" ).width();
	
	$( "#divLeft" ).height(windowHeight - (headerHeight+8));
	$( "#divRight" ).height(windowHeight - (headerHeight+4));
	$( "#divRight" ).width(windowWidth - (leftWidth+4));
}
function searchFormSubmit(formElement) {
    //#facet_doc_product=Amazon+CloudFront&amp;facet_doc_guide=Developer+Guide+(API+Version+2012-07-01)
    var si = $("#sel").attr("selectedIndex");
    var so = $("#sel").attr("options").item(si).value;
    if (so.indexOf("documentation") === 0) {
        var this_doc_product = $("#this_doc_product").val();
        var this_doc_guide =  $("#this_doc_guide").val();
        var action = "";
        var facet = "";
        if (so === "documentation-product" || so === "documentation-guide") {
            action += "?doc_product=" + encodeURIComponent(this_doc_product);
            facet += "#facet_doc_product=" + encodeURIComponent(this_doc_product);
            if (so === "documentation-guide") {
                action += "&doc_guide=" + encodeURIComponent(this_doc_guide);
                facet += "&facet_doc_guide=" + encodeURIComponent(this_doc_guide);
            }
        }
        if ($.browser.msie) {
            var sq = $("#sq").val();
            action += "&searchPath=" + encodeURIComponent(so);
            action += "&searchQuery=" + encodeURIComponent(sq);
            window.location.href = "/search/doc-search.html" + action + facet;
            return false;
        } else {
            formElement.action = "/search/doc-search.html" + facet;
        }
    } else {
        formElement.action = "http://aws.amazon.com/search";
    }
    return true;
}
