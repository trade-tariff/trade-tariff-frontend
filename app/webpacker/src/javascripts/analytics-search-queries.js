(function () {
  'use strict';

  var SearchQueriesLogger = function(){};

  SearchQueriesLogger.prototype.bindEvents = function(){
    $(document).on(
      'tariff:searchQuery',
      $.proxy(this.searchQuery, this)
    );
    $(document).on(
      'tariff:chooseSearchQueryOption',
      $.proxy(this.chooseQueryOption, this)
    );
  };

  SearchQueriesLogger.prototype.searchQuery = function(e, s2Data, s2Params){
    var queryTerm = s2Params.term,
        synonymsCount = s2Data.results.length;

    if (GOVUK.analytics) {
      GOVUK.analytics.trackEvent('synonyms', queryTerm, synonymsCount);
    }
  };

  SearchQueriesLogger.prototype.chooseQueryOption = function(e, select2Event){
    var synonymHit = !select2Event.params.data.newOption,
        optionChosen = select2Event.params.data.text;

    var actionName = synonymHit ? 'SynonymHit' : 'NoSynonymHit';

    if (GOVUK.analytics) {
      GOVUK.analytics.trackEvent(actionName, optionChosen);
    }
  };

  SearchQueriesLogger.prototype.trackEvent = function(action, label, value){
    if (GOVUK.analytics) {
      GOVUK.analytics.trackEvent('userSearch', 'searchterm:' + action, {
        label: label,
        value: value
      });
    }
  };

  var logger = new SearchQueriesLogger();
  logger.bindEvents();
})();
