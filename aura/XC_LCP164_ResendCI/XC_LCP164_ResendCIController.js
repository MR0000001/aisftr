({
	doInit: function (cmp, event, helper) {
		helper.doInit(cmp, event, helper);
	},

	cancel: function (cmp, event, helper) {
        $A.get('e.force:closeQuickAction').fire()
	},
	
	setEmail: function (cmp, event, helper) {
        helper.setEmail(cmp, event, helper);
	},

	send: function (cmp, event, helper) {
        helper.send(cmp, event, helper);
	}
})