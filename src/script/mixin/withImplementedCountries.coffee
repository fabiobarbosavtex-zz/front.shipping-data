define [], () ->
  ->
    @isCountryImplemented = (country) ->
      return country in ['ARG', 'BRA', 'CHL', 'COL', 'ECU', 'GTM', 'MEX', 'PER', 'PRY', 'URY', 'USA']
