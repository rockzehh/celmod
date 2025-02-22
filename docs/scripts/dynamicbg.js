var h = window.innerHeight;
var w = window.innerWidth;

var c = document.createElement('canvas');
c.setAttribute('style', 'position: fixed; top: 0px; left: 0px; z-index:-2');
c.setAttribute('width', w);
c.setAttribute('height', h);
document.body.appendChild(c);

var ctx = c.getContext('2d');

//var img = document.getElementById("bg");

var shade = ctx.createRadialGradient(w/2, h/2, h/2, w/2, h/2, w/2);
shade.addColorStop(0, "transparent");
shade.addColorStop(1, "#000");

//ctx.drawImage(img, 0, 0);
ctx.fillStyle = shade;
ctx.fillRect(0, 0, w, h);
var imgs = [];
var r = -1;
if(document.title.indexOf('A Living Project') > -1) {
    for(var i = 1; i < 8; i++) {
        imgs[i] = document.createElement('img');
        imgs[i].setAttribute('src', './images/bg/bg'+(i+1)+'.jpg');
        imgs[i].setAttribute('width', w);
        imgs[i].setAttribute('height', h);
        document.body.appendChild(imgs[i]);
        imgs[i].style.position = 'fixed';
        imgs[i].style.left = "0px";
        imgs[i].style.top = "0px";
        imgs[i].style.zIndex = -4;
        imgs[i].style.opacity = "0.0";
        imgs[i].style.display = 'none';
    }

    randomBG(-1);
    setInterval(keepHeights, 100);

    var logo = document.getElementById('logo');
    var main = document.getElementById('main');
    var footer = document.getElementById('footer');
    //hover(logo, true);
   // hover(main, false);
    //hover(footer, true);
}

function keepHeights() {
    if(r > -1) {
        for(var i = 0; i < 7; i++) {
            if(r == i) { imgs[i].style.zIndex = -3; } else {
                imgs[i].style.zIndex = -5
            }
        }
    }
}

function tr(obj, str) {
    obj.style.webkitTransform = str;
    obj.style.transform = str;
}

function randomBG(oldr) {
	while(r == oldr) {
	    r = Math.round((Math.random()*6));
	}
	imgs[r].style.display = 'block';
	imgs[r].style.opacity = "0.0";
	imgs[r].amt = [0, 1];
    tween(imgs[r], 500, 1, function() {
        for(var i = 0; i < 7; i++) {
	        if(i != r) {
                imgs[i].style.opacity = "0.0";
                imgs[i].style.display = 'none';
            }
        }
        setTimeout(function(){randomBG(r);}, 5000);
    });
    
}

function hover(obj, tilt) {
	if(obj) {
	    if(!obj.toggle) { obj.toggle = 1; }
	    if(!obj.rot) { obj.rot = [0.0, 0.0] }
	    if(obj.toggle == 1) {
	        obj.pos = [[0, -10], [0, 10]];
	        obj.toggle = 2;
	    } else {
	        obj.pos = [[0, 10], [0, -10]];
	        obj.toggle = 1;
	    }
	    if(tilt) {
	        obj.rot = [obj.rot[1], 5*(Math.random()-0.5)];
	    }
		tween(obj, 500, 1, function() {hover(obj, tilt);});
	}
}

function trans(obj, arg) {
	if(obj && obj.style) {
		if(obj.style.transform) {
			var t = obj.style.transform;
			var type = arg.substring(0, arg.indexOf("("));
			if(t.indexOf(type) > -1) {
				t = t.replace(t.substring(t.indexOf(type), t.indexOf(")", t.indexOf(type))+1), "");
			}
			t = t+" "+arg;
			tr(obj, t);
		} else {
			tr(obj, arg);
		}
	}
}

function tween(obj, time, rate, callback) {
	if(obj && time > 0) {
	    if(obj.amt) {
	        obj.amt[0] += (obj.amt[1]-obj.amt[0])/(time/rate);
	        obj.style.opacity = ""+obj.amt[0];
	    }
		if(obj.scale) {
			obj.scale[0] += (obj.scale[1]-obj.scale[0])/(time/rate);
			trans(obj, "scale("+obj.scale[0]+", "+obj.scale[0]+")");
		}
		if(obj.rot) {
			obj.rot[0] += (obj.rot[1]-obj.rot[0])/(time/rate);
			trans(obj, "rotate("+obj.rot[0]+"deg)");
		}
		if(obj.pos) {
			obj.pos[0][0] += (obj.pos[1][0]-obj.pos[0][0])/(time/rate);
			obj.pos[0][1] += (obj.pos[1][1]-obj.pos[0][1])/(time/rate);
			trans(obj, "translate("+obj.pos[0][0]+"px, "+obj.pos[0][1]+"px)");
		}
		if(obj.alpha) {
			obj.alpha[0] += (obj.alpha[1]-obj.alpha[0])/(time/rate);
			obj.style.opacity = obj.alpha[0];
		}
		time -= rate;
		setTimeout(function () {tween(obj, time, rate, callback);}, rate);
	} else if(time <= 0 && callback != null) {
		callback.call();
	}
}