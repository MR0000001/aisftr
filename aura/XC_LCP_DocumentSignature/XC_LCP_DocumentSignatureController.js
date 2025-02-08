({
    init: function (cmp, evt, hlp) {
        hlp.getInitInformation(cmp, evt, hlp);
        /*hlp.subscribe(cmp, evt, hlp)
        hlp.getDataInit(cmp, evt, hlp)*/
    },
    openUrl: function (cmp, evt, hlp) {
        const url = evt.getSource().get('v.value')
        cmp.set('v.iframeUrl', url)
        cmp.set('v.showModal', true)
    },
    switchModal: function (cmp, evt, hlp) {
        cmp.set('v.showModal', !cmp.get('v.showModal'))
    },
    refreshView: function (cmp, evt, hlp) {
        $A.get('e.force:refreshView').fire();
    }
})