function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function removeURLParameter(url, parameter) {
	var urlParts = url.split('?');
	if (urlParts.length >= 2) {
		var params = urlParts[1].split('&');
		var newParams = [];
		for (var i = 0; i < params.length; i++) {
			var parameterName = params[i].split('=')[0];
			if (parameterName !== parameter) {
				newParams.push(params[i]);
			}
		}
		return urlParts[0] + (newParams.length > 0 ? '?' + newParams.join('&') : '');
	}
	return url;
}

