define [], () ->
  ->
    @isCountryImplemented = (country) ->
      return country in ['ARG', 'BOL', 'BRA', 'CAN', 'CHL', 'COL', 'ECU', 'GTM', 'MEX', 'PER', 'PRY', 'PRT', 'URY', 'USA']
