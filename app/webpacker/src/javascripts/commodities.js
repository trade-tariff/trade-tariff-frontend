/*global $ */
/*jslint
 white: true */

// import IMask from 'imask';
// import debounce from "./debounce";

"use strict";

import CookieManager from './cookie-manager.js';

(function() {
  const IMask = require('imask');
  const debounce = require('./debounce');
  const htmlEscaper = require('html-escaper');
  const cookieManagerInstance = new CookieManager();

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
        @name GOVUK.tariff.tabs
        @object
        @description Tabbing behaviours
      */
      tabs : {
          /**
            @name GOVUK.tariff.tabs.initialize
            @function
            @description adds tabbing behaviour
            @requires jquery.tabs.js
            @param {String} context Element in which to add behaviours
          */
          initialize : function (context) {
              var $container = $(context);

              if ($container.find('.nav-tabs').length) {
                  $container.tabs();
              }
          }
      },
      tabLinkFocuser:{
          /**
            @name GOVUK.tariff.tabLinkFocuser.initialize
            @function
            @description opens relevant tab and focuses on element inside its content
            @param {String} context Element in which to add behaviours
          */
          initialize : function (context) {
              var hash = window.location.hash,
                  pattern = /^#(import|export)\-(measure)\-(\d+)$/;

              if (hash.match(pattern)) {
                var matches = hash.match(pattern),
                    tabId = 'tab-' + matches[1],
                    entity = matches[2],
                    entityId = matches[3];

                    $('#' + tabId + ' a').trigger('click');
                    $('#' + entity + '-' + entityId).trigger("focus");
              }
          }
      },
      /**
        @name GOVUK.tariff.breadcrumbs
        @object
        @description Adds show/hide behaviour to breadcrumbs on narrow viewports
      */
      breadcrumbs : {
          fullTree: $('.js-tariff-breadcrumbs .js-full-tree'),
          summaryTree: $('.js-tariff-breadcrumbs .js-summary-tree'),
          showBtn: $('.js-tariff-breadcrumbs .js-show-full-tree-link'),
          /**
            @name GOVUK.tariff.breadcrumbs.initialize
            @function
            @description adds tabbing behaviour
            @requires jquery.tabs.js
            @param {String} context Element in which to add behaviours
          */
          initialize : function () {
              this.hideTree();
              this.showBtn.on("click", function() {
                  GOVUK.tariff.breadcrumbs.showTree();
              });
          },
          hideTree : function() {
              this.fullTree.hide();
              this.summaryTree.show();
          },
          showTree : function() {
              this.fullTree.show();
              this.summaryTree.hide();
          }
      },
      /**
        @name GOVUK.tariff.tablePopup
        @object
        @description Adds popup behaviour to tariff table cells
      */
      tablePopup : {
          html : ['<div class="info-content"><h2 id="dialog-title" class="govuk-visually-hidden">',
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
          adapt : function ($linkElm) {
              var that = this;

              var url = $linkElm.attr('href'),
                  $popup = $('#popup'),
                  $popupInner = $popup.find('div.info-inner'),
                  $dialogTitle = $('#dialog-title'),
                  $closeBtn = $popup.find('.close a'),
                  $mask = $('#mask'),
                  loader = '<img src="" alt="Content is loading" class="loader" />',
                  htmlContent,
                  popupCSS;

              htmlContent = $("[data-popup=" + $linkElm.data('popup-ref') + "]").html();
              $popupInner.html(htmlContent);

              // reset the tabindex of the heading
              $dialogTitle
                  .attr('tabindex', 0)
                  .trigger("focus");
              $popup
                  .attr({
                      'tabindex' : -1,
                      'role' : 'dialog',
                      'aria-labelledby' : 'dialog-title'
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
                  $popup.fadeOut(400, function(){
                      $mask.slideUp('fast', function() { $(this).remove(); $popup.remove(); });
                  });
                  that.scrollInPopup(false);
                  $linkElm.trigger("focus");
              }

              // return focus to the trigger link when the lightbox closes
              $closeBtn.on('click', function (e) {
                  $linkElm.trigger("focus")
              });

              // dialogs need focus to be retained until closed so control tabbing
              $popup.on('keydown', function (e) {
                  if (e.which == 9){

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
          scrollInPopup : function (scrollPopup) {
            if (scrollPopup == true) {
              $('body, html').css('overflow','hidden');
            } else {
              $('body, html').css('overflow','');
            }
          },
          open : function ($target) {
              var title = this.html[0] + 'Conditions' + this.html[1];

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
          initialize : function (context) {
              var that = this,
                  hash = window.location.hash,
                  $linkElms = $('table td a.reference', context),
                  tabId;

              $('#import-measure-references, #export-measure-references').hide();

              $linkElms.each(function (idx, linkElm) {
                  var $linkElm = $(linkElm);

                  $linkElm.attr('title', 'Opens in a popup');
                  $linkElm.on('click', function (e) {
                      that.open($(this));
                      return false;
                  });
              });

              if (window.location.hash.length > 0) {
                var anchor = window.location.hash.split('#')[1] ;

                var popupLink = context.querySelector('a[data-popup-ref="' + anchor + '"]') ;
                if (popupLink) {
                  // switch to tab which contains the link
                  var containingTabId = $(popupLink).parents('.govuk-tabs__panel').attr('id') ;
                  if (containingTabId) {
                    $('.govuk-tabs__list-item a[href="' + containingTabId  + '"]').trigger('click') ;
                  }

                  // click link for popup
                  $(popupLink).trigger('click');
                } else {
                  var matches = anchor.match(/^order-number-(\d+)$/) ;
                  var unknownOrderPopupLink = $('a[data-popup-ref="unknown-quota-definition"]');

                  if (matches && unknownOrderPopupLink.length > 0) {
                    $('div[data-popup="unknown-quota-definition"] .unknown-quota-order-number').text(matches[1]);
                    that.open(unknownOrderPopupLink) ;
                  }
                }
              }
          }
      },
      /**
        @name GOVUK.tariff.searchForm
        @object
        @description container for searchForm behaviour
      */
      searchForm : {
          /**
            @name GOVUK.tariff.datePicker.initialize
            @function
            @description initializes namespace
          */
          initialize: function () {
            var toggledDataControls = ['js-date-picker'],
                namespace = this;

            $(toggledDataControls).each(function(idx, element){
              namespace.toggledControl.initialize(element);
            });

            $('form').on('click', 'button[type=submit]', function(e) {
              this.closest('form').trigger("submit");
            });

            this.responsivePlaceholder.initialize();
          },
          toggledControl: {
            initialize: function(control) {
              var   $controlForm = $('fieldset[class~=' + control + ']'),
                    $infoPara = $controlForm.find('span.text'),
                    $fields = $controlForm.find('span.fields');

                $fields.hide();

                $controlForm.on('click', 'a', function (e) {
                    $infoPara.toggle();
                    $fields.toggle();

                    if ($fields.is(":visible")) {
                      $fields.find("input, select").filter(":visible").first().trigger("focus");
                    }

                    return false;
                });

                $controlForm.on('click', 'a.submit', function(e) {
                  $controlForm.closest('form').trigger("submit");
                });

                $('form').on("submit", function () {
                  var today = new Date();
                  var fday = $('#tariff_date_day'),
                      fmonth = $('#tariff_date_month'),
                      fyear = $('#tariff_date_year');
                  if (today.getDate().toString() == fday.val() &&
                      (today.getMonth() + 1).toString() == fmonth.val() &&
                      today.getFullYear().toString() == fyear.val()) {
                    fday.attr("disabled", "disabled");
                    fmonth.attr("disabled", "disabled");
                    fyear.attr("disabled", "disabled");
                  }
                  return true;
                });
            }
          },
          responsivePlaceholder: {
           initialize: function () {
              var namespace = this;
              namespace.onResize();
              $(window).on("debouncedresize", function( event ) {
                  namespace.onResize();
              });
            },
            onResize: function () {
              var w = $(window).width(),
                  placeholderElem = $('.js-search-header').find('input#search_t'),
                  placeholderText = '';
              if (w > 440) {
                placeholderText = 'Enter the name of the goods or commodity code';
              } else {
                placeholderText = 'Name of goods or comm code';
              }
              $(placeholderElem).attr('placeholder', placeholderText);
            }
          }
      },
      /**
        @name GOVUK.tariff.searchHighlight
        @object
        @description highlights search terms
      */
      searchHighlight : {
        initialize : function () {
          if (GOVUK.tariff.utils.getUrlParam('t')) {
            var words = GOVUK.tariff.utils.getUrlParam('t').replace(/\+/g, ' ');
            var passages = '.js-results-subset a,' + // Search results page
                           '.js-commodities .description'; // Commodity tree (headings) page
            $(passages).mark(words, {className: 'highlight'});
          }
        }
      },
      /**
        @name GOVUK.tariff.countryPicker
        @object
        @description container for country picker behaviour
      */
      countryPicker : {
        initialize : function () {
          var control = 'js-country-picker',
              $controlForm = $('fieldset[class~=' + control + ']');

          // Submit button not needed if JavaScript is enabled
          $controlForm.find('.search-submit').hide();

          this.showOrHideResetLink($controlForm);

          if ($("#tariff_date_date").length > 0) {
                // configure and activate datepicker
                var datepickerInput = $("#tariff_date_date")[0];
                var datepickerButton = $("#search-datepicker-button")[0];
                var datepickerDialog = $("#search-datepicker-dialog")[0];

                var dtpicker = new DatePicker(datepickerInput, datepickerButton, datepickerDialog);
                dtpicker.init();

                // on datepicker change, update individual date inputs
                $("#tariff_date_date").on("change", function() {
                  var parts = $("#tariff_date_date").val().split("/");

                  $("#tariff_date_day").val(parts[0]);
                  $("#tariff_date_month").val(parts[1]);
                  $("#tariff_date_year").val(parts[2]);
                });

                // with JS enable link style submit
                $(".js-date-picker a.submit").show();

                // input mask
                var dateMask = IMask($("#tariff_date_date")[0], {
                  mask: Date,  // enable date mask

                  // other options are optional
                  pattern: 'd{/}`m{/}`Y',  // Pattern mask with defined blocks, default is 'd{.}`m{.}`Y'
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
                    }
                  },
                  // define date -> str convertion
                  format: function (date) {
                    var day = date.getDate();
                    var month = date.getMonth() + 1;
                    var year = date.getFullYear();

                    if (day < 10) day = "0" + day;
                    if (month < 10) month = "0" + month;

                    return [day, month, year].join('/');
                  },
                  // define str -> date convertion
                  parse: function (str) {
                    var yearMonthDay = str.split('/');
                    return new Date(parseInt(yearMonthDay[2], 10), parseInt(yearMonthDay[1], 10) - 1, parseInt(yearMonthDay[0], 10));
                  },

                  // optional interval options
                  min: new Date(2008, 0, 1),  // defaults to `1900-01-01`
                  max: new Date((new Date()).getFullYear() + 1, 11, 31),  // defaults to `9999-01-01`

                  autofix: false,  // defaults to `false`

                  // also Pattern options can be set
                  lazy: false,

                  // and other common options
                  overwrite: true  // defaults to `false`
                });
              }

              $(".js-show").show();
        },
        showOrHideResetLink : function ($controlForm) {
          if ($controlForm.find('select').val() != '') {
            $('.reset-country-picker').css('display', 'table-cell');
          }
        }
      },
      /**
        @name hovers
        @object
        @description adding hovers for item numbers
      */
      hovers : {
        /**
          @name init
          @function
          @description initialize the namespace
          @param {String} context Element in which to add behaviours
        */
        init : function (context) {
          var $terms = $('dt.chapter-code, dt.heading-code, dt.section-number, dl.sections dt', context),
              controlClass;

          controlClass = function (idx, action, $descriptionLink) {
            return function () {
              $descriptionLink[action + 'Class']('hover');
              $terms.eq(idx)[action + 'Class']('hover');
            }
          };

          $terms.each(function (idx) {
            var $this = $(this),
                $description = $this.next('dd').removeClass('hover'),
                $descriptionLink = $description.find('>a');

            if (!$descriptionLink.length) {
              $descriptionLink = $description.find('>h1 a');
              if (!$descriptionLink.length) { return; }
            }

            $descriptionLink.removeClass('hover');

            // fire the link when it's term is clicked
            $this.on('click', function () {
              // clear classes in case content is cached with pjax
              $(this).removeClass('hover');
              $descriptionLink.removeClass('hover');
              GOVUK.tariff.utils.triggerClick.call($descriptionLink[0]);
            });

            $this.add($descriptionLink).hover(
              controlClass(idx, 'add', $descriptionLink),
              controlClass(idx, 'remove', $descriptionLink)
            );
          });
        }
      },
      /**
        @name selectBoxes
        @object
        @description configuring the select boxes used within the tariff
      */
      selectBoxes : {
        initialize : function () {
          $('.js-select').each(function() {
            accessibleAutocomplete.enhanceSelectElement({
              selectElement: $(this)[0],
              dropdownArrow: function() {
                return "<span class='autocomplete__arrow'></span>";
              },
            });
          });

          $('.js-country-picker-select').each(function() {
            (function(element) {
              accessibleAutocomplete.enhanceSelectElement({
                selectElement: element[0],
                minLength: 2,
                autoselect: true,
                showAllValues: true,
                confirmOnBlur: true,
                alwaysDisplayArrow: true,
                displayMenu: 'overlay',
                dropdownArrow: function() {
                  return "<span class='autocomplete__arrow'></span>";
                },
                onConfirm: function(confirmed) {
                  var code = /\((\w\w)\)/.test(confirmed) ? /\((\w\w)\)/.exec(confirmed)[1] : null;
                  $(this.selectElement).val(code);
                  $(this.selectElement).siblings('input[name$="[anchor]"]').val(window.location.hash.substring(1)); // maintain the tab
                  $(this.selectElement).parents('form:first').trigger("submit");
                },
              });

              $('#' + element[0].id.replace('-select', '')).on('focus', function(event) {
                $(event.currentTarget).val('')
              });

            })($(this));
          });

        $('.js-commodity-picker-select').each(function() {
          const debugEnabled = $(this).data('debug') || false;
          function inputValueTemplate(result) {
            if (result && result.id) {
              return result.id;
            } else {
              return result;
            }
          }

          function suggestionTemplate(result) {
            // The first suggestion is always the input text
            if (typeof result === 'string') {
              return result;
            } else if (result && result.text && result.query) {
              let enhanced = result.text.replace(result.query, `<strong>$&</strong>`);

              if (result.formatted_suggestion_type) {
                enhanced = `<span data-resource-id="${result.resource_id}" data-suggestion-type="${result.formatted_suggestion_type}">${enhanced}</span>`;
                enhanced += `<span class="suggestion-type">${result.formatted_suggestion_type}</span>`;
              }

              return enhanced;
            }
          }
          (function(element) {
            const autocomplete_input_id = $(element).data('autocomplete-input-id') || 'q';

            let options = [];
            let searching = true;

            $(element).on('change', 'input[type="text"]', function(ev) {
              $(element).parents('form').find('.js-commodity-picker-target').val($(ev.target).val());
            });

            // Avoid the default keydown behaviour of the autocomplete library and
            // auto submit on Mousclick, Enter or Tab ourselves
            // when an element receives Enter, the form is submitted
            // when an element selected with arrow keys, the form is not submitted
            const handleSubmitEvent = function(ev) {
              if (ev.type === 'click' || ev.key === 'Enter' || ev.key === 'Tab') {
                const form = $(element).parents('form');
                const suggestionType = $(ev.target).find('[data-suggestion-type]').data('suggestion-type');
                const resourceId = $(ev.target).find('[data-resource-id]').data('resource-id');
                let text = $(ev.target).text();

                ev.preventDefault();

                if (text === '') {
                  text = $(element).find('input[type="text"]').val();
                }

                if (suggestionType) {
                  text = text.replace(suggestionType, '');
                }

                form.find('.js-commodity-picker-target').val(text);

                if (resourceId) {
                    form.find('.js-commodity-picker-resource-id').val(resourceId);
                }

                form.submit();
              }
            };

            // Both the input and the list items need to be handled for keyboard events
            $(element).on('keydown', 'li[id^="q__option--"]', handleSubmitEvent);
            $(element).on('keydown', 'input[type="text"]', handleSubmitEvent);
            // Handle mouse click
            $(element).on('click', 'li[id^="q__option--"]', handleSubmitEvent);


            accessibleAutocomplete({
              element: element[0],
              id: autocomplete_input_id,
              minLength: 2,
              showAllValues: false,
              confirmOnBlur: false,
              displayMenu: 'overlay',
              placeholder: 'Enter the name of the goods or commodity code',
              tNoResults: () => searching ? 'Searching...' : 'No results found',
              templates: {
                inputValue: inputValueTemplate,
                suggestion: suggestionTemplate,
              },
              onConfirm: function(text) {
                let obj = null;

                options.forEach(function(option) {
                  if (option.text == text) {
                    obj = option;
                  }
                });

                if (obj) {
                  $(element).parents('form:first').find('.js-commodity-picker-target').val(obj.id);

                  if (typeof($(element).data('nosubmit')) == 'undefined') {
                    $(element).parents('form:first').trigger('submit');
                  }
                }
              },
              source: debounce(function(query, populateResults) {
                const escapedQuery = htmlEscaper.escape(query);

                const opts = {
                  term: escapedQuery,
                };

                $.ajax({
                  type: 'GET',
                  url: $('.path_info').data('searchSuggestionsPath'),
                  data: opts,
                  success: function(data) {
                    const results = data.results;
                    const newSource = [];
                    let exactMatch = false;
                    options = [];
                    searching = false;

                    results.forEach(function(result) {
                      newSource.push(result);
                      options.push(result);

                      if (result.text.toLowerCase() == escapedQuery.toLowerCase()) {
                        exactMatch = true;
                      }
                    });

                    if ($.inArray(escapedQuery.toLowerCase(), newSource) < 0) {
                      newSource.unshift(escapedQuery.toLowerCase());
                      options.unshift({
                        id: escapedQuery.toLowerCase(),
                        text: escapedQuery.toLowerCase(),
                        suggestion_type: 'exact',
                        newOption: true,
                      });
                    }

                    populateResults(newSource);

                    $(document).trigger('tariff:searchQuery', [data, opts]);
                  },
                  error: function() {
                    populateResults([]);
                  },
                });
              }, 400, false),
            });
          })($(this));
        });
        }
      },
      /**
        @name utils
        @namespace
        @description utilities for the GOVUK.tariff namespace
      */
      utils : {
        /**
          @name triggerClick
          @function
          @description trigger a click on an element. To be on an element via the call() method
          @param {String} event Name of the event to trigger
        */
        triggerClick : function () {
           if (document.createEvent) {
               var evt = document.createEvent("HTMLEvents");
               evt.initEvent('click', true, true ); // event type, bubbling, cancelable
               return this.dispatchEvent(evt);
           } else {
               // dispatch for IE
               var evt = document.createEventObject();
               this.trigger("click");
           }
        },
        /**
          @name cookies
          @object
          @description controls the getting and setting of cookies
        */
        cookies : {
          set : function (cname, cvalue, exdays) {
            var d = new Date();
            d.setTime(d.getTime() + (exdays*24*60*60*1000));
            var expires = "expires="+d.toUTCString();
            document.cookie = cname + "=" + cvalue + "; " + expires;
          },
          get : function (cname) {
            var name = cname + "=";
            var ca = document.cookie.split(';');
            for(var i = 0; i < ca.length; i++) {
              var c = ca[i];
              while (c.charAt(0) == ' ') {
                c = c.substring(1);
              }
              if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
              }
            }
            return "";
          }
        },
        /**
          @name getUrlParam
          @function
          @description gets a variable value from the query string based on its name
        */
        getUrlParam : function (name) {
          var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
          if (results==null) {
            return null;
          } else {
            return results[1] || 0;
          }
        }
      },
      measuresTable: {
        initialize: function() {
          this.$tables = $("table.measures");

          if (this.$tables.length <= 0) {
            return;
          }

          this.bindEvents();
          this.enforceHeights()
        },
        bindEvents: function() {
          var self = this;

          $(window).on("resize", function() {
            self.enforceHeights();
          });

          $(".js-tabs a").on("click", function() {
            self.enforceHeights();
          });
        },
        enforceHeights: function() {
          var windowWidth = $(window).width();

          this.$tables.each(function() {
            var table = $(this);

            table.find("dt.has_children").each(function() {
              var dt = $(this);
              var secondColumn = dt.closest("td").next();
              var height = 0;
              secondColumn.find("span.table-line").each(function() {
                height += $(this).outerHeight();
              });

              if (windowWidth > 839) {
                dt.css("min-height", height + "px");
              } else {
                dt.css("min-height", 0);
              }
            });
          });
        }
      },
      copyCode: {
        initialize: function() {
          let that = this;

          $('#copy_comm_code').on("click", function(event) {
            that.copy(event)
          });
        },
        copy: function(event) {
          let commodityCode = $('.commodity-header').data('comm-code')
          this.copyToClipboard(commodityCode);

          $(".copied").css("text-indent", "0");
          $(".copied")
            .delay(500)
            .fadeOut(750, function() {
              $(".copied").css("text-indent", "-999em");
              $(".copied").css("display", "block");
            });
          event.preventDefault();
        },
        copyToClipboard: function(text) {
          let temp = $("<input>");
          $("body").append(temp);
          temp
            .val(text)
            .trigger('select');
          document.execCommand("copy");
          temp.remove();
        }
      },
      /**
        @name initialize
        @function
        @description adds behaviours
        @param {Element} content Element in which to add behaviours
      */
      onLoad : function (context) {
          if (context === undefined) {
            context = document.body;
          }

          this.tabs.initialize(context);
          this.tablePopup.initialize(context);
          this.tabLinkFocuser.initialize(context);
          this.hovers.init(context);
          this.selectBoxes.initialize();
          this.searchForm.initialize();
          this.searchHighlight.initialize();
          this.countryPicker.initialize();
          this.breadcrumbs.initialize();
          this.measuresTable.initialize();
          this.copyCode.initialize();
      }
  };

}());
