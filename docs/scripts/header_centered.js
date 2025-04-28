var favicon = document.createElement('link');
favicon.setAttribute('rel', 'shortcut icon');
favicon.setAttribute('type', 'image/png');
favicon.setAttribute('href', 'https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/docs/favicon.ico');
document.body.appendChild(favicon);

var logo = document.createElement('a');
logo.setAttribute('href', './');
document.body.appendChild(logo);
logo.innerHTML = '<div id="logo" style="text-align: center; margin-left: auto; margin-right: auto;"><img src="https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/docs/images/logo.png" style="border: solid 1px #000;"></img></div>';
