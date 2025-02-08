({
    doInit: function (cmp, evt, hlp) {
        hlp.doInit(cmp, evt, hlp)
    },

    setPickCountry: function (cmp, evt, hlp) {
        let selectedOptionValue = evt.getParam('value')
        hlp.setPickCountry(cmp, selectedOptionValue, hlp)
    },

    setPickCategory: function (cmp, evt, hlp) {
        let selectedOptionValue = evt.getParam('value')
        cmp.set('v.address.category', selectedOptionValue)
        hlp.sendChanges(cmp, hlp)
    },

    setPickStreetType: function (cmp, evt, hlp) {
        let selectedOptionValue = evt.getParam('value')
        cmp.set('v.address.streetType', selectedOptionValue)
        hlp.sendChanges(cmp, hlp)
    },

    setPickProvince: function (cmp, evt, hlp) {
        let selectedOptionValue = evt.getParam('value')
        cmp.set('v.address.province', selectedOptionValue)
        hlp.sendChanges(cmp, hlp)
    },

    saveAddress: function (cmp, evt, hlp) {
        hlp.handleSaveButtonClick(cmp, evt, hlp)
    },

    onValidate: function (cmp, evt, hlp) {
        hlp.checkFieldsBeforeValidate(cmp, evt, hlp)
    },

    cancel: function (cmp, evt, hlp) {
        hlp.cancel(cmp, evt, hlp)
    },

    handlePrimaryButtonClick: function (cmp, evt, hlp) {
        hlp.handlePrimaryButtonClick(cmp, evt, hlp)
    },

    skipValidation: function (cmp, evt, hlp) {
        hlp.skipValidation(cmp, evt, hlp)
    },

    /* ---------------------- Methods for autocompleting address ---------------------- */

    typingAddress: function (cmp, evt, hlp) {
        hlp.setDeelay(cmp, hlp, cmp.get("v.address.address"), hlp.typingAddress);
        hlp.sendChanges(cmp, hlp)
    },

    typingCity: function (cmp, evt, hlp) {
        hlp.setDeelay(cmp, hlp, cmp.get("v.address.address"), hlp.typingCity);
        hlp.sendChanges(cmp, hlp)
    },

    typingZip: function (cmp, evt, hlp) {
        hlp.setDeelay(cmp, hlp, cmp.get("v.address.address"), hlp.typingZip);
        hlp.sendChanges(cmp, hlp)
    },

    checkAddress: function (cmp, evt, hlp) {
        console.log('Clicked address search bar')
        hlp.checkAddress(cmp, evt, hlp)
    },

    checkCity: function (cmp, evt, hlp) {
        console.log('Clicked city search bar')
        hlp.checkCity(cmp, evt, hlp)
    },

    checkZip: function (cmp, evt, hlp) {
        console.log('Clicked zip search bar')
        hlp.checkZip(cmp, evt, hlp)
    },

    checkNumber: function (cmp, evt, hlp) {
        console.log('Clicked street number field')
    },

    selectAddress: function (cmp, evt, hlp) {
        var inputString = evt.target.id
        hlp.selectAddress(cmp, evt, hlp, inputString)
    },

    selectCity: function (cmp, evt, hlp) {
        var inputString = evt.target.id
        hlp.selectCity(cmp, evt, hlp, inputString)
    },

    selectZip: function (cmp, evt, hlp) {
        var inputString = evt.target.id
        hlp.selectZip(cmp, evt, hlp, inputString)
    },

    onModify: function (cmp, evt, hlp) {
        console.log('onModify')
        hlp.onModify(cmp, evt, hlp)
    },

    clearAddress: function (cmp, evt, hlp) {
        hlp.clearAddress(cmp, evt, hlp)
    },

    editPressed: function (cmp, evt, hlp) {
        hlp.editPressed(cmp, evt, hlp)
    },

    sendChanges: function (cmp, evt, hlp) {
        hlp.sendChanges(cmp, hlp)
    }
})