vtex.curl.config({
  baseUrl: '/shipui/',
  paths: {
    'component': 'js/component',
    'template': 'js/templates',
    'translation': 'js/translation'
  },
  apiName: 'require'
});

i18n.init({
	lang: window.vtex.i18n.getLocale(),
	load: 'current',
	fallbackLng: 'pt-BR',	
	customLoad: function (lng, ns, options, loadComplete) {
		vtex.require('translation/'+lng).then(function(dictionary){
			return loadComplete(null, dictionary);
		});
	}
});
	

	