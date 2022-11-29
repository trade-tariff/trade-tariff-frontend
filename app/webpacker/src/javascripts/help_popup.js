$("#close_box").on("click", function(event) {
  hide_help_popup();
})

$("#close_box_longer").on("click", function(event) {
  let expiresInDays = 28;
  setCookie("show_digital_assistant_popup", "disable", expiresInDays);
  hide_help_popup();
})

function hide_help_popup() {
  $("#help_popup").css("display", "none");
}

setTimeout(show_help_popup, 30000);

function show_help_popup() {
  let cookieValue = getCookie("show_digital_assistant_popup");
  let isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

  if (cookieValue == "" && isMobile == false) {
    $("#help_popup").fadeIn(1000);
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
