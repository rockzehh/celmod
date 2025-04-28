var favicon = document.createElement('link');
favicon.setAttribute('rel', 'shortcut icon');
favicon.setAttribute('type', 'image/png');
favicon.setAttribute('href', 'https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/docs/favicon.ico');
document.body.appendChild(favicon);

var bg_logo = 'url(https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/docs/images/logo.png) 0 0 repeat-y';
var logo = document.createElement('a');
logo.setAttribute('href', 'celmod.rockzehh.net/index.html');
document.body.appendChild(logo);
logo.innerHTML = '<img src="https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/docs/images/logo.png" style="border: solid 1px #000;"></img>';
