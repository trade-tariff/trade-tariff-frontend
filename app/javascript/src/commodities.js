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
        set: function(cname, cvalue, exdays) {
          const d = new Date();
          d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
          const expires = 'expires=' + d.toUTCString();
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
        if (results == null) {
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
      this.measuresTable.initialize();
      this.copyCode.initialize();
    },
  };
}());
