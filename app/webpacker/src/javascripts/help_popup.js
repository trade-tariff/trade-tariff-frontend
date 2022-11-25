$("#close_box").on("click", function(event) {
  hide_help_popup();
})

$("#close_box_longer").on("click", function(event) {
  setCookie("show_digital_assistant_popup", "disable", 28);
  hide_help_popup();
})

function show_help_popup() {
  $("#help_popup").fadeIn(1000);
}

function hide_help_popup() {
  $("#help_popup").css("display", "none");
}

setTimeout(checkCookieAndBrowser, 30000);

function checkCookieAndBrowser() {
  let cookieValue = getCookie("show_digital_assistant_popup");
  var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

  if (cookieValue == "" && isMobile == false) {
    show_help_popup();
  }
}

function setCookie(cname, cvalue, exdays) {
  const d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  let expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires;
}

function getCookie(cname) {
  let name = cname + "=";
  let ca = document.cookie.split(';');
  for(let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}
