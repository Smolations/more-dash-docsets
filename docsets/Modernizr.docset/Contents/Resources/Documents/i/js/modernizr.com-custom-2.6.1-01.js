/*
   Hi!

   We're thrilled you're taking a peek at the Modernizr.com source code. Be advised though: this JavaScript file
   is specifically built for use on modernizr.com -- meaning, it's no use copying or linking to directly. Rather,
   check out our documentation at modernizr.com/docs/ and build your own custom version at modernizr.com/download/
*/

/* Modernizr 2.6.1 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-fontface-boxshadow-multiplebgs-opacity-cssanimations-csscolumns-cssgradients-csstransforms-csstransitions-history-localstorage-postmessage-sessionstorage-inlinesvg-svg-touch-printshiv-mq-cssclasses-addtest-teststyles-testprop-testallprops-prefixes-domprefixes-load
 */
;window.Modernizr=function(a,b,c){function B(a){j.cssText=a}function C(a,b){return B(m.join(a+";")+(b||""))}function D(a,b){return typeof a===b}function E(a,b){return!!~(""+a).indexOf(b)}function F(a,b){for(var d in a){var e=a[d];if(!E(e,"-")&&j[e]!==c)return b=="pfx"?e:!0}return!1}function G(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:D(f,"function")?f.bind(d||b):f}return!1}function H(a,b,c){var d=a.charAt(0).toUpperCase()+a.slice(1),e=(a+" "+o.join(d+" ")+d).split(" ");return D(b,"string")||D(b,"undefined")?F(e,b):(e=(a+" "+p.join(d+" ")+d).split(" "),G(e,b,c))}var d="2.6.1",e={},f=!0,g=b.documentElement,h="modernizr",i=b.createElement(h),j=i.style,k,l={}.toString,m=" -webkit- -moz- -o- -ms- ".split(" "),n="Webkit Moz O ms",o=n.split(" "),p=n.toLowerCase().split(" "),q={svg:"http://www.w3.org/2000/svg"},r={},s={},t={},u=[],v=u.slice,w,x=function(a,c,d,e){var f,i,j,k=b.createElement("div"),l=b.body,m=l?l:b.createElement("body");if(parseInt(d,10))while(d--)j=b.createElement("div"),j.id=e?e[d]:h+(d+1),k.appendChild(j);return f=["&#173;",'<style id="s',h,'">',a,"</style>"].join(""),k.id=h,(l?k:m).innerHTML+=f,m.appendChild(k),l||(m.style.background="",g.appendChild(m)),i=c(k,a),l?k.parentNode.removeChild(k):m.parentNode.removeChild(m),!!i},y=function(b){var c=a.matchMedia||a.msMatchMedia;if(c)return c(b).matches;var d;return x("@media "+b+" { #"+h+" { position: absolute; } }",function(b){d=(a.getComputedStyle?getComputedStyle(b,null):b.currentStyle)["position"]=="absolute"}),d},z={}.hasOwnProperty,A;!D(z,"undefined")&&!D(z.call,"undefined")?A=function(a,b){return z.call(a,b)}:A=function(a,b){return b in a&&D(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(b){var c=this;if(typeof c!="function")throw new TypeError;var d=v.call(arguments,1),e=function(){if(this instanceof e){var a=function(){};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(v.call(arguments)));return Object(g)===g?g:f}return c.apply(b,d.concat(v.call(arguments)))};return e}),r.touch=function(){var c;return"ontouchstart"in a||a.DocumentTouch&&b instanceof DocumentTouch?c=!0:x(["@media (",m.join("touch-enabled),("),h,")","{#modernizr{top:9px;position:absolute}}"].join(""),function(a){c=a.offsetTop===9}),c},r.postmessage=function(){return!!a.postMessage},r.history=function(){return!!a.history&&!!history.pushState},r.multiplebgs=function(){return B("background:url(https://),url(https://),red url(https://)"),/(url\s*\(.*?){3}/.test(j.background)},r.boxshadow=function(){return H("boxShadow")},r.opacity=function(){return C("opacity:.55"),/^0.55$/.test(j.opacity)},r.cssanimations=function(){return H("animationName")},r.csscolumns=function(){return H("columnCount")},r.cssgradients=function(){var a="background-image:",b="gradient(linear,left top,right bottom,from(#9f9),to(white));",c="linear-gradient(left top,#9f9, white);";return B((a+"-webkit- ".split(" ").join(b+a)+m.join(c+a)).slice(0,-a.length)),E(j.backgroundImage,"gradient")},r.csstransforms=function(){return!!H("transform")},r.csstransitions=function(){return H("transition")},r.fontface=function(){var a;return x('@font-face {font-family:"font";src:url("https://")}',function(c,d){var e=b.getElementById("smodernizr"),f=e.sheet||e.styleSheet,g=f?f.cssRules&&f.cssRules[0]?f.cssRules[0].cssText:f.cssText||"":"";a=/src/i.test(g)&&g.indexOf(d.split(" ")[0])===0}),a},r.localstorage=function(){try{return localStorage.setItem(h,h),localStorage.removeItem(h),!0}catch(a){return!1}},r.sessionstorage=function(){try{return sessionStorage.setItem(h,h),sessionStorage.removeItem(h),!0}catch(a){return!1}},r.svg=function(){return!!b.createElementNS&&!!b.createElementNS(q.svg,"svg").createSVGRect},r.inlinesvg=function(){var a=b.createElement("div");return a.innerHTML="<svg/>",(a.firstChild&&a.firstChild.namespaceURI)==q.svg};for(var I in r)A(r,I)&&(w=I.toLowerCase(),e[w]=r[I](),u.push((e[w]?"":"no-")+w));return e.addTest=function(a,b){if(typeof a=="object")for(var d in a)A(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,f&&(g.className+=" "+(b?"":"no-")+a),e[a]=b}return e},B(""),i=k=null,e._version=d,e._prefixes=m,e._domPrefixes=p,e._cssomPrefixes=o,e.mq=y,e.testProp=function(a){return F([a])},e.testAllProps=H,e.testStyles=x,g.className=g.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(f?" js "+u.join(" "):""),e}(this,this.document),function(a,b){function k(a,b){var c=a.createElement("p"),d=a.getElementsByTagName("head")[0]||a.documentElement;return c.innerHTML="x<style>"+b+"</style>",d.insertBefore(c.lastChild,d.firstChild)}function l(){var a=r.elements;return typeof a=="string"?a.split(" "):a}function m(a){var b=i[a[g]];return b||(b={},h++,a[g]=h,i[h]=b),b}function n(a,c,f){c||(c=b);if(j)return c.createElement(a);f||(f=m(c));var g;return f.cache[a]?g=f.cache[a].cloneNode():e.test(a)?g=(f.cache[a]=f.createElem(a)).cloneNode():g=f.createElem(a),g.canHaveChildren&&!d.test(a)?f.frag.appendChild(g):g}function o(a,c){a||(a=b);if(j)return a.createDocumentFragment();c=c||m(a);var d=c.frag.cloneNode(),e=0,f=l(),g=f.length;for(;e<g;e++)d.createElement(f[e]);return d}function p(a,b){b.cache||(b.cache={},b.createElem=a.createElement,b.createFrag=a.createDocumentFragment,b.frag=b.createFrag()),a.createElement=function(c){return r.shivMethods?n(c,a,b):b.createElem(c)},a.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+l().join().replace(/\w+/g,function(a){return b.createElem(a),b.frag.createElement(a),'c("'+a+'")'})+");return n}")(r,b.frag)}function q(a){a||(a=b);var c=m(a);return r.shivCSS&&!f&&!c.hasCSS&&(c.hasCSS=!!k(a,"article,aside,figcaption,figure,footer,header,hgroup,nav,section{display:block}mark{background:#FF0;color:#000}")),j||p(a,c),a}function v(a){var b,c=a.getElementsByTagName("*"),d=c.length,e=RegExp("^(?:"+l().join("|")+")$","i"),f=[];while(d--)b=c[d],e.test(b.nodeName)&&f.push(b.applyElement(w(b)));return f}function w(a){var b,c=a.attributes,d=c.length,e=a.ownerDocument.createElement(t+":"+a.nodeName);while(d--)b=c[d],b.specified&&e.setAttribute(b.nodeName,b.nodeValue);return e.style.cssText=a.style.cssText,e}function x(a){var b,c=a.split("{"),d=c.length,e=RegExp("(^|[\\s,>+~])("+l().join("|")+")(?=[[\\s,>+~#.:]|$)","gi"),f="$1"+t+"\\:$2";while(d--)b=c[d]=c[d].split("}"),b[b.length-1]=b[b.length-1].replace(e,f),c[d]=b.join("}");return c.join("{")}function y(a){var b=a.length;while(b--)a[b].removeNode()}function z(a){function g(){clearTimeout(d._removeSheetTimer),b&&b.removeNode(!0),b=null}var b,c,d=m(a),e=a.namespaces,f=a.parentWindow;return!u||a.printShived?a:(typeof e[t]=="undefined"&&e.add(t),f.attachEvent("onbeforeprint",function(){g();var d,e,f,h=a.styleSheets,i=[],j=h.length,l=Array(j);while(j--)l[j]=h[j];while(f=l.pop())if(!f.disabled&&s.test(f.media)){try{d=f.imports,e=d.length}catch(m){e=0}for(j=0;j<e;j++)l.push(d[j]);try{i.push(f.cssText)}catch(m){}}i=x(i.reverse().join("")),c=v(a),b=k(a,i)}),f.attachEvent("onafterprint",function(){y(c),clearTimeout(d._removeSheetTimer),d._removeSheetTimer=setTimeout(g,500)}),a.printShived=!0,a)}var c=a.html5||{},d=/^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i,e=/^<|^(?:a|b|button|code|div|fieldset|form|h1|h2|h3|h4|h5|h6|i|iframe|img|input|label|li|link|ol|option|p|param|q|script|select|span|strong|style|table|tbody|td|textarea|tfoot|th|thead|tr|ul)$/i,f,g="_html5shiv",h=0,i={},j;(function(){try{var a=b.createElement("a");a.innerHTML="<xyz></xyz>",f="hidden"in a,j=a.childNodes.length==1||function(){b.createElement("a");var a=b.createDocumentFragment();return typeof a.cloneNode=="undefined"||typeof a.createDocumentFragment=="undefined"||typeof a.createElement=="undefined"}()}catch(c){f=!0,j=!0}})();var r={elements:c.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",shivCSS:c.shivCSS!==!1,supportsUnknownElements:j,shivMethods:c.shivMethods!==!1,type:"default",shivDocument:q,createElement:n,createDocumentFragment:o};a.html5=r,q(b);var s=/^$|\b(?:all|print)\b/,t="html5shiv",u=!j&&function(){var c=b.documentElement;return typeof b.namespaces!="undefined"&&typeof b.parentWindow!="undefined"&&typeof c.applyElement!="undefined"&&typeof c.removeNode!="undefined"&&typeof a.attachEvent!="undefined"}();r.type+=" print",r.shivPrint=z,z(b)}(this,document),function(a,b,c){function d(a){return o.call(a)=="[object Function]"}function e(a){return typeof a=="string"}function f(){}function g(a){return!a||a=="loaded"||a=="complete"||a=="uninitialized"}function h(){var a=p.shift();q=1,a?a.t?m(function(){(a.t=="c"?B.injectCss:B.injectJs)(a.s,0,a.a,a.x,a.e,1)},0):(a(),h()):q=0}function i(a,c,d,e,f,i,j){function k(b){if(!o&&g(l.readyState)&&(u.r=o=1,!q&&h(),l.onload=l.onreadystatechange=null,b)){a!="img"&&m(function(){t.removeChild(l)},50);for(var d in y[c])y[c].hasOwnProperty(d)&&y[c][d].onload()}}var j=j||B.errorTimeout,l={},o=0,r=0,u={t:d,s:c,e:f,a:i,x:j};y[c]===1&&(r=1,y[c]=[],l=b.createElement(a)),a=="object"?l.data=c:(l.src=c,l.type=a),l.width=l.height="0",l.onerror=l.onload=l.onreadystatechange=function(){k.call(this,r)},p.splice(e,0,u),a!="img"&&(r||y[c]===2?(t.insertBefore(l,s?null:n),m(k,j)):y[c].push(l))}function j(a,b,c,d,f){return q=0,b=b||"j",e(a)?i(b=="c"?v:u,a,b,this.i++,c,d,f):(p.splice(this.i++,0,a),p.length==1&&h()),this}function k(){var a=B;return a.loader={load:j,i:0},a}var l=b.documentElement,m=a.setTimeout,n=b.getElementsByTagName("script")[0],o={}.toString,p=[],q=0,r="MozAppearance"in l.style,s=r&&!!b.createRange().compareNode,t=s?l:n.parentNode,l=a.opera&&o.call(a.opera)=="[object Opera]",l=!!b.attachEvent&&!l,u=r?"object":l?"script":"img",v=l?"script":u,w=Array.isArray||function(a){return o.call(a)=="[object Array]"},x=[],y={},z={timeout:function(a,b){return b.length&&(a.timeout=b[0]),a}},A,B;B=function(a){function b(a){var a=a.split("!"),b=x.length,c=a.pop(),d=a.length,c={url:c,origUrl:c,prefixes:a},e,f,g;for(f=0;f<d;f++)g=a[f].split("="),(e=z[g.shift()])&&(c=e(c,g));for(f=0;f<b;f++)c=x[f](c);return c}function g(a,e,f,g,i){var j=b(a),l=j.autoCallback;j.url.split(".").pop().split("?").shift(),j.bypass||(e&&(e=d(e)?e:e[a]||e[g]||e[a.split("/").pop().split("?")[0]]||h),j.instead?j.instead(a,e,f,g,i):(y[j.url]?j.noexec=!0:y[j.url]=1,f.load(j.url,j.forceCSS||!j.forceJS&&"css"==j.url.split(".").pop().split("?").shift()?"c":c,j.noexec,j.attrs,j.timeout),(d(e)||d(l))&&f.load(function(){k(),e&&e(j.origUrl,i,g),l&&l(j.origUrl,i,g),y[j.url]=2})))}function i(a,b){function c(a,c){if(a){if(e(a))c||(j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}),g(a,j,b,0,h);else if(Object(a)===a)for(n in m=function(){var b=0,c;for(c in a)a.hasOwnProperty(c)&&b++;return b}(),a)a.hasOwnProperty(n)&&(!c&&!--m&&(d(j)?j=function(){var a=[].slice.call(arguments);k.apply(this,a),l()}:j[n]=function(a){return function(){var b=[].slice.call(arguments);a&&a.apply(this,b),l()}}(k[n])),g(a[n],j,b,n,h))}else!c&&l()}var h=!!a.test,i=a.load||a.both,j=a.callback||f,k=j,l=a.complete||f,m,n;c(h?a.yep:a.nope,!!i),i&&c(i)}var j,l,m=this.yepnope.loader;if(e(a))g(a,0,m,0);else if(w(a))for(j=0;j<a.length;j++)l=a[j],e(l)?g(l,0,m,0):w(l)?B(l):Object(l)===l&&i(l,m);else Object(a)===a&&i(a,m)},B.addPrefix=function(a,b){z[a]=b},B.addFilter=function(a){x.push(a)},B.errorTimeout=1e4,b.readyState==null&&b.addEventListener&&(b.readyState="loading",b.addEventListener("DOMContentLoaded",A=function(){b.removeEventListener("DOMContentLoaded",A,0),b.readyState="complete"},0)),a.yepnope=k(),a.yepnope.executeStack=h,a.yepnope.injectJs=function(a,c,d,e,i,j){var k=b.createElement("script"),l,o,e=e||B.errorTimeout;k.src=a;for(o in d)k.setAttribute(o,d[o]);c=j?h:c||f,k.onreadystatechange=k.onload=function(){!l&&g(k.readyState)&&(l=1,c(),k.onload=k.onreadystatechange=null)},m(function(){l||(l=1,c(1))},e),i?k.onload():n.parentNode.insertBefore(k,n)},a.yepnope.injectCss=function(a,c,d,e,g,i){var e=b.createElement("link"),j,c=i?h:c||f;e.href=a,e.rel="stylesheet",e.type="text/css";for(j in d)e.setAttribute(j,d[j]);g||(n.parentNode.insertBefore(e,n),m(c,0))}}(this,document),Modernizr.load=function(){yepnope.apply(window,[].slice.call(arguments,0))};



// Asynchronous Typekit loading
(function() {
  var config = {
    kitId: 'uqi6bct',
    scriptTimeout: 3000
  };
  var h=document.getElementsByTagName("html")[0];h.className+=" wf-loading";var t=setTimeout(function(){h.className=h.className.replace(/( |^)wf-loading( |$)/g,"");h.className+=" wf-inactive"},config.scriptTimeout);var tk=document.createElement("script");tk.src='//use.typekit.net/'+config.kitId+'.js';tk.type="text/javascript";tk.async="true";tk.onload=tk.onreadystatechange=function(){var a=this.readyState;if(a&&a!="complete"&&a!="loaded")return;clearTimeout(t);try{Typekit.load(config)}catch(b){}};var s=document.getElementsByTagName("script")[0];s.parentNode.insertBefore(tk,s)
})();




// Download page awesomeness, custom tests
Modernizr.addTest({
  // BlobBuilder
  "blobbuilder": function() {
    return  !!(window.BlobBuilder || window.MozBlobBuilder || window.WebKitBlobBuilder);
  },
  // Blob ctor supersedes BlobBuilder
  "blob": function() {
    try {
      return !!new Blob();
    } catch (e) {
      return false;
    }
  },
  // Blob URL support
  "bloburls": function() {
    return !!(window.URL && window.URL.createObjectURL || window.webkitURL && window.webkitURL.createObjectURL);;
  },
  // download attribute
  "download": function() {
    return "download" in document.createElement("a");
  },
  // FormData
  "formdata": function() {
    return  !!(window.FormData && "append" in window.FormData.prototype);
  }
});

var _bTestResults    = {}
  , _bBeaconComplete = function(data) {
  // window.console && console.log('beaconComplete',data);
}

function crawlMod(mod){
  var Modernizr = mod || window.Modernizr;
  for (var feat in Modernizr) {

    if (/^_/.test(feat) || typeof Modernizr[feat] == 'function') continue;

    if (/input|video|audio/.test(feat) && Modernizr[feat]){
      for (var thing in Modernizr[feat]){
        _bTestResults[feat + ':' +thing] = Modernizr[feat][thing] ? '1' : '0';
      }
    } else {
      _bTestResults[feat] = Modernizr[feat] ? '1' : '0';
    }
  }
};

function beacon(){
  var _bTestKey = 'agt1YS1wcm9maWxlcnINCxIEVGVzdBib2KQGDA';
  var _bScript = document.createElement('script');
  _bScript.src = 'http://www.browserscope.org/user/beacon/' + _bTestKey + '?callback=_bBeaconComplete';
  _bScript.setAttribute('async', 'true');
  var scripts = document.getElementsByTagName('script');
  var lastScript = scripts[scripts.length - 1];
  lastScript.parentNode.insertBefore(_bScript, lastScript);
}



// Modernizr.com Custom Initialization

// Dynamic loading configuration
Modernizr.load([
  {
    load: '//ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js',
    complete: function () {
      if (!window.jQuery) {
        Modernizr.load('/i/js/jquery-1.7.min.js');
      }

      // beacon to browserscope on homepage.
      $('body#home').length && setTimeout(function(){
        jQuery.getScript(jQuery('.buttons .dev').attr('href'), function() {
          // crawl the *new* modernizr not that old one.
          crawlMod(window.Modernizr);
          beacon();
        });
      }, 2000);
    }
  }, {
    test: Modernizr.csstransitions && Modernizr.csstransforms,
    yep: '/i/css/animations.css'
  },

  // custom site script; simple for now
  '/i/js/modernizr.script-2.1.1.js',

  // load up google analytics and livestats
  '/i/js/analytics.js'
]);