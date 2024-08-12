/* global $ */
/* jslint
 white: true */

// import IMask from 'imask';
// import debounce from "./debounce";

'use strict';

(function() {
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
      initialize: function() {
        const toggledDataControls = ['js-date-picker'];
        const namespace = this;

        $(toggledDataControls).each(function(idx, element) {
          namespace.toggledControl.initialize(element);
        });

        $('form').on('click', 'button[type=submit]', function(e) {
          $(this).closest('form').trigger('submit');
        });

        this.responsivePlaceholder.initialize();
      },
      toggledControl: {
        initialize: function(control) {
          const $controlForm = $('fieldset[class~=' + control + ']');
          const $infoPara = $controlForm.find('span.text');
          const $fields = $controlForm.find('span.fields');

          $fields.hide();

          $controlForm.on('click', 'a', function(e) {
            $infoPara.toggle();
            $fields.toggle();

            if ($fields.is(':visible')) {
              $fields.find('input, select').filter(':visible').first().trigger('focus');
            }

            return false;
          });

          $controlForm.on('click', 'a.submit', function(e) {
            $controlForm.closest('form').trigger('submit');
          });

          $('form').on('submit', function() {
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
        initialize: function() {
          const namespace = this;
          namespace.onResize();
          $(window).on('debouncedresize', function( event ) {
            namespace.onResize();
          });
        },
        onResize: function() {
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
        @name GOVUK.tariff.searchHighlight
        @object
        @description highlights search terms
      */
    searchHighlight: {
      initialize: function() {
        if (GOVUK.tariff.utils.getUrlParam('t')) {
          const words = GOVUK.tariff.utils.getUrlParam('t').replace(/\+/g, ' ');
          const passages = '.js-results-subset a,' + // Search results page
                           '.js-commodities .description'; // Commodity tree (headings) page
          $(passages).mark(words, {className: 'highlight'});
        }
      },
    },
    /**
        @name GOVUK.tariff.countryPicker
        @object
        @description container for country picker behaviour
      */
    countryPicker: {
      initialize: function() {
        const control = 'js-country-picker';
        const $controlForm = $('fieldset[class~=' + control + ']');

        // Submit button not needed if JavaScript is enabled
        $controlForm.find('.search-submit').hide();

        this.showOrHideResetLink($controlForm);

        if ($('#tariff_date_date').length > 0) {
          // configure and activate datepicker
          const datepickerInput = $('#tariff_date_date')[0];
          const datepickerButton = $('#search-datepicker-button')[0];
          const datepickerDialog = $('#search-datepicker-dialog')[0];

          const dtpicker = new DatePicker(datepickerInput, datepickerButton, datepickerDialog);
          dtpicker.init();

          // on datepicker change, update individual date inputs
          $('#tariff_date_date').on('change', function() {
            const parts = $('#tariff_date_date').val().split('/');

            $('#tariff_date_day').val(parts[0]);
            $('#tariff_date_month').val(parts[1]);
            $('#tariff_date_year').val(parts[2]);
          });

          // with JS enable link style submit
          $('.js-date-picker a.submit').show();

          // input mask
          const dateMask = IMask($('#tariff_date_date')[0], {
            mask: Date, // enable date mask

            // other options are optional
            pattern: 'd{/}`m{/}`Y', // Pattern mask with defined blocks, default is 'd{.}`m{.}`Y'
            // you can provide your own blocks definitions, default blocks for date mask are:
            blocks: {
              d: {
                mask: IMask.MaskedRange,
                from: 1,
                to: 31,
                maxLength: 2,
              },
              m: {
                mask: IMask.MaskedRange,
                from: 1,
                to: 12,
                maxLength: 2,
              },
              Y: {
                mask: IMask.MaskedRange,
                // from: 2008,
                to: (new Date()).getFullYear() + 1,
              },
            },
            // define date -> str convertion
            format: function(date) {
              let day = date.getDate();
              let month = date.getMonth() + 1;
              const year = date.getFullYear();

              if (day < 10) day = '0' + day;
              if (month < 10) month = '0' + month;

              return [day, month, year].join('/');
            },
            // define str -> date convertion
            parse: function(str) {
              const yearMonthDay = str.split('/');
              return new Date(parseInt(yearMonthDay[2], 10), parseInt(yearMonthDay[1], 10) - 1, parseInt(yearMonthDay[0], 10));
            },

            // optional interval options
            min: new Date(2008, 0, 1), // defaults to `1900-01-01`
            max: new Date((new Date()).getFullYear() + 1, 11, 31), // defaults to `9999-01-01`

            autofix: false, // defaults to `false`

            // also Pattern options can be set
            lazy: false,

            // and other common options
            overwrite: true, // defaults to `false`
          });
        }

        $('.js-show').show();
      },
      showOrHideResetLink: function($controlForm) {
        if ($controlForm.find('select').val() != '') {
          $('.reset-country-picker').css('display', 'table-cell');
        }
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
      triggerClick: function() {
        if (document.createEvent) {
          var evt = document.createEvent('HTMLEvents');
          evt.initEvent('click', true, true ); // event type, bubbling, cancelable
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
        set: function(cname, cvalue, exdays) {
          const d = new Date();
          d.setTime(d.getTime() + (exdays*24*60*60*1000));
          const expires = 'expires='+d.toUTCString();
          document.cookie = cname + '=' + cvalue + '; ' + expires;
        },
        get: function(cname) {
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
      getUrlParam: function(name) {
        const results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results==null) {
          return null;
        } else {
          return results[1] || 0;
        }
      },
    },
    measuresTable: {
      initialize: function() {
        this.$tables = $('table.measures');

        if (this.$tables.length <= 0) {
          return;
        }

        this.bindEvents();
        this.enforceHeights();
      },
      bindEvents: function() {
        const self = this;

        $(window).on('resize', function() {
          self.enforceHeights();
        });

        $('.js-tabs a').on('click', function() {
          self.enforceHeights();
        });
      },
      enforceHeights: function() {
        const windowWidth = $(window).width();

        this.$tables.each(function() {
          const table = $(this);

          table.find('dt.has_children').each(function() {
            const dt = $(this);
            const secondColumn = dt.closest('td').next();
            let height = 0;
            secondColumn.find('span.table-line').each(function() {
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
      initialize: function() {
        const that = this;

        $('#copy_comm_code').on('click', function(event) {
          that.copy(event);
        });
      },
      copy: function(event) {
        const commodityCode = $('.commodity-header').data('comm-code');
        this.copyToClipboard(commodityCode);

        $('.copied').css('text-indent', '0');
        $('.copied')
            .delay(500)
            .fadeOut(750, function() {
              $('.copied').css('text-indent', '-999em');
              $('.copied').css('display', 'block');
            });
        event.preventDefault();
      },
      copyToClipboard: function(text) {
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
    onLoad: function(context) {
      if (context === undefined) {
        context = document.body;
      }

      this.searchForm.initialize();
      this.searchHighlight.initialize();
      this.countryPicker.initialize();
      this.measuresTable.initialize();
      this.copyCode.initialize();
    },
  };
}());
