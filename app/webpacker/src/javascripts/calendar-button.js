/*
*   This content is licensed according to the W3C Software License at
*   https://www.w3.org/Consortium/Legal/2015/copyright-software-and-document
*
*   File:   calendar-button.js
*/

window.CalendarButtonInput = function (inputNode, buttonNode, datepicker) {
  this.inputNode    = inputNode;
  this.buttonNode   = buttonNode;
  this.imageNode    = false;

  this.datepicker = datepicker;

  this.defaultLabel = 'Choose Date';

  this.keyCode = Object.freeze({
    'ENTER': 13,
    'SPACE': 32
  });
};

CalendarButtonInput.prototype.init = function () {
  this.buttonNode.addEventListener('click', this.handleClick.bind(this));
  this.buttonNode.addEventListener('keydown', this.handleKeyDown.bind(this));
  this.buttonNode.addEventListener('focus', this.handleFocus.bind(this));
};

CalendarButtonInput.prototype.handleKeyDown = function (event) {
  var flag = false;

  switch (event.keyCode) {

    case this.keyCode.SPACE:
    case this.keyCode.ENTER:
      this.datepicker.show();
      this.datepicker.setFocusDay();
      flag = true;
      break;

    default:
      break;
  }

  if (flag) {
    event.stopPropagation();
    event.preventDefault();
  }
};

CalendarButtonInput.prototype.handleClick = function (event) {
  if (!this.datepicker.isOpen()) {
    this.datepicker.show();
    this.datepicker.setFocusDay();
  }
  else {
    this.datepicker.hide();
  }

  event.stopPropagation();
  event.preventDefault();

};

CalendarButtonInput.prototype.setLabel = function (str) {
  if (typeof str === 'string' && str.length) {
    str = ', ' + str;
  }
  this.buttonNode.setAttribute('aria-label', this.defaultLabel + str);
};

CalendarButtonInput.prototype.setFocus = function () {
  this.buttonNode.focus();
};

CalendarButtonInput.prototype.leftPad = function(val, length, char = '0') {
  var endString = val.toString();

  while (endString.length < length) {
    endString = char + endString;
  }

  return endString;
};

CalendarButtonInput.prototype.setDate = function (day) {
  var dateString = this.leftPad(day.getDate(), 2) + '/' + this.leftPad(day.getMonth() + 1, 2) + '/' + day.getFullYear();
  this.inputNode.value = dateString;

  var event = document.createEvent('HTMLEvents');
  event.initEvent('change', true, false);
  this.inputNode.dispatchEvent(event);
};

CalendarButtonInput.prototype.getDate = function () {
  return this.inputNode.value;
};

CalendarButtonInput.prototype.getDateLabel = function () {
  var label = '';

  var parts = this.inputNode.value.split('/');

  if ((parts.length === 3) &&
      Number.isInteger(parseInt(parts[0])) &&
      Number.isInteger(parseInt(parts[1])) &&
      Number.isInteger(parseInt(parts[2]))) {
    var month = parseInt(parts[0]) - 1;
    var day = parseInt(parts[1]);
    var year = parseInt(parts[2]);

    label = this.datepicker.getDateForButtonLabel(year, month, day);
  }

  return label;
};

CalendarButtonInput.prototype.handleFocus = function () {
  var dateLabel = this.getDateLabel();

  if (dateLabel) {
    this.setLabel('selected date is ' + dateLabel);
  }
  else {
    this.setLabel('');
  }
};
