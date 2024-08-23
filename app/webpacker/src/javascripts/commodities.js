/* global $ */
/* jslint
 white: true */

// import IMask from 'imask';
// import debounce from "./debounce";

'use strict';

(function () {
  const IMask = require('imask');
  const debounce = require('./debounce');

  global.GOVUK = global.GOVUK || {};
  /**
    @name GOVUK.tariff
    @memberOf GOVUK
    @namespace
    @description A set of methods for handling behaviours with Trade tariff commodities
    @requires jquery 1.6.2
  */

  GOVUK.tariff = {
    /**
        @name GOVUK.tariff.tablePopup
        @object
        @description Adds popup behaviour to tariff table cells
      */
    tablePopup: {
      html: ['<div class="info-content"><h2 id="dialog-title" class="govuk-visually-hidden">',
        '</h2>' +
        '<p class="close"><a href="#">Close</a></p>' +
        '<div class="info-inner">' +
        '<p>Content unavailable</p>' +
        '</div>' +
        '</div>'],
      /**
            @name GOVUK.tariff.tablePopup.adapt
            @function
            @description adapts the disclaimer popup for reuse
            @param {Object} $this jQuery-wrapped link that fired the popup
          */
      adapt: function ($linkElm) {
        const that = this;

        const url = $linkElm.attr('href');
        const $popup = $('#popup');
        const $popupInner = $popup.find('div.info-inner');
        const $dialogTitle = $('#dialog-title');
        const $closeBtn = $popup.find('.close a');
        const $mask = $('#mask');
        const loader = '<img src="" alt="Content is loading" class="loader" />';
        let htmlContent;
        let popupCSS;

        htmlContent = $('[data-popup=' + $linkElm.data('popup-ref') + ']').html();
        $popupInner.html(htmlContent);

        // reset the tabindex of the heading
        $dialogTitle
          .attr('tabindex', 0)
          .trigger('focus');
        $popup
          .attr({
            'tabindex': -1,
            'role': 'dialog',
            'aria-labelledby': 'dialog-title',
          })
          .on('click', function (e) {
            // If the user has clicked outside of the actual popup but not on the mask
            // Will switch to CSS when IE11+ support is required
            if (e.target.id == 'popup') {
              closePopup();
            }
          });

        $mask
          .on('click', function () {
            closePopup();
          });

        closePopup = function () {
          $popup.fadeOut(400, function () {
            $mask.slideUp('fast', function () {
              $(this).remove(); $popup.remove();
            });
          });
          that.scrollInPopup(false);
          $linkElm.trigger('focus');
        };

        // return focus to the trigger link when the lightbox closes
        $closeBtn.on('click', function (e) {
          $linkElm.trigger('focus');
        });

        // dialogs need focus to be retained until closed so control tabbing
        $popup.on('keydown', function (e) {
          if (e.which == 9) {
            // cancel tabbing from the close button (assumed this is the last link)
            if (e.target.nodeName.toLowerCase() === 'a') {
              if (!event.shiftKey) {
                return false;
              }
            } else {
              // popup removes tabindex from the title by default so re-apply it
              if (e.target.nodeName.toLowerCase() === 'h2') {
                e.target.tabIndex = 0;
              }

              // cancel reverse-tabbing out of the popup
              if (event.shiftKey) {
                return false;
              }
            }
          }

          return true;
        });
      },
      /**
            @name GOVUK.tariff.tablePopup.open
            @function
            @description opens the popup
            @param {Element} $target Target of the click event
          */
      scrollInPopup: function (scrollPopup) {
        if (scrollPopup == true) {
          $('body, html').css('overflow', 'hidden');
        } else {
          $('body, html').css('overflow', '');
        }
      },
      open: function ($target) {
        const title = this.html[0] + 'Conditions' + this.html[1];

        BetaPopup.maskOpacity = 0.2;
        BetaPopup.popup(title, 'tariff-info');
        this.adapt($target);
        this.scrollInPopup(true);
      },
      /**
            @name GOVUK.tariff.tablePopup.initialize
            @function
            @description initializes the popup behaviour
            @param {String} context Element in which to add behaviours
          */
      initialize: function (context) {
        const that = this;
        const hash = window.location.hash;
        const $linkElms = $('table td a.reference', context);
        let tabId;

        $('#import-measure-references, #export-measure-references').hide();

        $linkElms.each(function (idx, linkElm) {
          const $linkElm = $(linkElm);

          $linkElm.attr('title', 'Opens in a popup');
          $linkElm.on('click', function (e) {
            that.open($(this));
            return false;
          });
        });

        if (window.location.hash.length > 0) {
          const anchor = window.location.hash.split('#')[1];

          const popupLink = context.querySelector('a[data-popup-ref="' + anchor + '"]');
          if (popupLink) {
            // switch to tab which contains the link
            const containingTabId = $(popupLink).parents('.govuk-tabs__panel').attr('id');
            if (containingTabId) {
              $('.govuk-tabs__list-item a[href="' + containingTabId + '"]').trigger('click');
            }

            // click link for popup
            $(popupLink).trigger('click');
          } else {
            const matches = anchor.match(/^order-number-(\d+)$/);
            const unknownOrderPopupLink = $('a[data-popup-ref="unknown-quota-definition"]');

            if (matches && unknownOrderPopupLink.length > 0) {
              $('div[data-popup="unknown-quota-definition"] .unknown-quota-order-number').text(matches[1]);
              that.open(unknownOrderPopupLink);
            }
          }
        }
      },
    },
    /**
        @name GOVUK.tariff.searchForm
        @object
        @description container for searchForm behaviour
      */
    searchForm: {
      /**
            @name GOVUK.tariff.datePicker.initialize
            @function
            @description initializes namespace
          */
      initialize: function () {
        const toggledDataControls = ['js-date-picker'];
        const namespace = this;

        $(toggledDataControls).each(function (idx, element) {
          namespace.toggledControl.initialize(element);
        });

        $('form').on('click', 'button[type=submit]', function (e) {
          $(this).closest('form').trigger('submit');
        });

        this.responsivePlaceholder.initialize();
      },
      toggledControl: {
        initialize: function (control) {
          const $controlForm = $('fieldset[class~=' + control + ']');
          const $infoPara = $controlForm.find('span.text');
          const $fields = $controlForm.find('span.fields');

          $fields.hide();

          $controlForm.on('click', 'a', function (e) {
            $infoPara.toggle();
            $fields.toggle();

            if ($fields.is(':visible')) {
              $fields.find('input, select').filter(':visible').first().trigger('focus');
            }

            return false;
          });

          $controlForm.on('click', 'a.submit', function (e) {
            $controlForm.closest('form').trigger('submit');
          });

          $('form').on('submit', function () {
            const today = new Date();
            const fday = $('#tariff_date_day');
            const fmonth = $('#tariff_date_month');
            const fyear = $('#tariff_date_year');
            if (today.getDate().toString() == fday.val() &&
              (today.getMonth() + 1).toString() == fmonth.val() &&
              today.getFullYear().toString() == fyear.val()) {
              fday.attr('disabled', 'disabled');
              fmonth.attr('disabled', 'disabled');
              fyear.attr('disabled', 'disabled');
            }
            return true;
          });
        },
      },
      responsivePlaceholder: {
        initialize: function () {
          const namespace = this;
          namespace.onResize();
          $(window).on('debouncedresize', function (event) {
            namespace.onResize();
          });
        },
        onResize: function () {
          const w = $(window).width();
          const placeholderElem = $('.js-search-header').find('input#search_t');
          let placeholderText = '';
          if (w > 440) {
            placeholderText = 'Enter the name of the goods or commodity code';
          } else {
            placeholderText = 'Name of goods or comm code';
          }
          $(placeholderElem).attr('placeholder', placeholderText);
        },
      },
    },
    /**
        @name utils
        @namespace
        @description utilities for the GOVUK.tariff namespace
      */
    utils: {
      /**
          @name triggerClick
          @function
          @description trigger a click on an element. To be on an element via the call() method
          @param {String} event Name of the event to trigger
        */
      triggerClick: function () {
        if (document.createEvent) {
          var evt = document.createEvent('HTMLEvents');
          evt.initEvent('click', true, true); // event type, bubbling, cancelable
          return this.dispatchEvent(evt);
        } else {
          // dispatch for IE
          var evt = document.createEventObject();
          this.trigger('click');
        }
      },
      /**
          @name cookies
          @object
          @description controls the getting and setting of cookies
        */
      cookies: {
        set: function (cname, cvalue, exdays) {
          const d = new Date();
          d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
          const expires = 'expires=' + d.toUTCString();
          document.cookie = cname + '=' + cvalue + '; ' + expires;
        },
        get: function (cname) {
          const name = cname + '=';
          const ca = document.cookie.split(';');
          for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) == ' ') {
              c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
              return c.substring(name.length, c.length);
            }
          }
          return '';
        },
      },
      /**
          @name getUrlParam
          @function
          @description gets a variable value from the query string based on its name
        */
      getUrlParam: function (name) {
        const results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results == null) {
          return null;
        } else {
          return results[1] || 0;
        }
      },
    },
    measuresTable: {
      initialize: function () {
        this.$tables = $('table.measures');

        if (this.$tables.length <= 0) {
          return;
        }

        this.bindEvents();
        this.enforceHeights();
      },
      bindEvents: function () {
        const self = this;

        $(window).on('resize', function () {
          self.enforceHeights();
        });

        $('.js-tabs a').on('click', function () {
          self.enforceHeights();
        });
      },
      enforceHeights: function () {
        const windowWidth = $(window).width();

        this.$tables.each(function () {
          const table = $(this);

          table.find('dt.has_children').each(function () {
            const dt = $(this);
            const secondColumn = dt.closest('td').next();
            let height = 0;
            secondColumn.find('span.table-line').each(function () {
              height += $(this).outerHeight();
            });

            if (windowWidth > 839) {
              dt.css('min-height', height + 'px');
            } else {
              dt.css('min-height', 0);
            }
          });
        });
      },
    },
    copyCode: {
      initialize: function () {
        const that = this;

        $('#copy_comm_code').on('click', function (event) {
          that.copy(event);
        });
      },
      copy: function (event) {
        const commodityCode = $('.commodity-header').data('comm-code');
        this.copyToClipboard(commodityCode);

        $('.copied').css('text-indent', '0');
        $('.copied')
          .delay(500)
          .fadeOut(750, function () {
            $('.copied').css('text-indent', '-999em');
            $('.copied').css('display', 'block');
          });
        event.preventDefault();
      },
      copyToClipboard: function (text) {
        const temp = $('<input>');
        $('body').append(temp);
        temp
          .val(text)
          .trigger('select');
        document.execCommand('copy');
        temp.remove();
      },
    },
    /**
        @name initialize
        @function
        @description adds behaviours
        @param {Element} content Element in which to add behaviours
      */
    onLoad: function (context) {
      if (context === undefined) {
        context = document.body;
      }

      this.tablePopup.initialize(context);
      this.searchForm.initialize();
      this.measuresTable.initialize();
      this.copyCode.initialize();
    },
  };
}());
