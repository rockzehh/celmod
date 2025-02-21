var favicon = document.createElement('link');
favicon.setAttribute('rel', 'shortcut icon');
favicon.setAttribute('type', 'image/png');
favicon.setAttribute('href', './favicon.ico');
document.body.appendChild(favicon);

var bg_logo = 'url(./images/logo.png) 0 0 repeat-y';
var logo = document.createElement('a');
logo.setAttribute('href', './');
document.body.appendChild(logo);
logo.innerHTML = '<img src="./images/logo.png" style="border: solid 1px #000;"></img>';
