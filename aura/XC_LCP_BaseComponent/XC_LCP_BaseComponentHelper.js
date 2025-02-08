({
	//METODI GENERICI
	callMethod: function (cmp, method, params) {
		return new Promise((resolve, reject) => {
			var me = this
			$A.getCallback(function () {
				var action = cmp.get('c.' + method)
				if (params) action.setParams(params)
				action.setCallback(me, function (res) {
					if (res.getState() === 'SUCCESS') {
						resolve(res.getReturnValue())
					} else if (cmp.isValid() && res.getState() === 'ERROR') {
						var error = 'Si è verificato un errore'
						if (res.getError() && res.getError()[0] && res.getError()[0].pageErrors && res.getError()[0].pageErrors[0]) {
							error = res.getError()[0].pageErrors[0].message
						} else if (res.getError()[0]) {
							error = res.getError()[0].message
						}
						reject(error)
					} else {
						reject(res)
					}
				})
				$A.enqueueAction(action)
			})()
		})
	},
	notifySuccess: function (message, title) {
		var toastEvent = $A.get('e.force:showToast')
		toastEvent.setParams({
			'title': title || $A.get('$Label.c.XC_CL_Success'),
			'message': message,
			'type': 'success',
			'duration': 8000
		})
		toastEvent.fire()
	},
	notifyError: function (message, title) {
		var toastEvent = $A.get('e.force:showToast')
		toastEvent.setParams({
			'title': title || 'Error',
			'message': message,
			'type': 'error',
			'duration': 8000
		})
		toastEvent.fire()
	},
	isSalesforce1: function () {
		return $A.get('$Browser.formFactor') !== 'DESKTOP'
	},
	openTab: function (scope) {
		$A.get('e.force:navigateToObjectHome').fire({
			'scope': scope
		})
	},
	openListView: function (scope, listViewId) {
		$A.get('e.force:navigateToList').fire({
			'scope': scope,
			'listViewId': listViewId
		})
	}
})