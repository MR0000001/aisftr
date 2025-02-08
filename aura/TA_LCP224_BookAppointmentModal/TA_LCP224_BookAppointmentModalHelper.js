({
    getAppointments : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> getAppointments >> Start');
        
        if(!component.get('v.reschedule') && component.get('v.leadId') == null) {
            let _helper = this;
            let getWorkOrderToSchedule = component.get('c.getWorkOrderToSchedule');
            
            getWorkOrderToSchedule.setParam('workOrderId', component.get('v.workOrderId'));
            getWorkOrderToSchedule.setCallback(this, function(response) {
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> getWorkOrderToSchedule >> Start getConfigs callback');
                if(response.getState() == "SUCCESS") { 
                    if(component.get('v.bookNow')) {
                        _helper.confirm(component, response.getReturnValue());
                    } else {
                        _helper.getAvailableAppointments(component, response.getReturnValue());
                    }
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                    _helper.sendError(component);
                    component.set('v.isSpinnerVisible', false);
                }  
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> getWorkOrderToSchedule >> End getConfigs callback');
            });
    
            component.set('v.isSpinnerVisible', true);
            $A.enqueueAction(getWorkOrderToSchedule);
        } else {
            this.getAvailableAppointments(component, component.get('v.workOrderId'));
        }
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> getAppointments >> End');
    },

    getAvailableAppointments : function(component, workOrderId) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> getAvailableAppointments >> Start');
        
        let _helper = this;
        let getAvailableAppointments = component.get('c.getAvailableAppointments');

        console.log('@@>> workOrderId >>> ' + workOrderId);
        console.log('@@>> leadId >>> ' + component.get('v.leadId'));
        console.log('@@>> opportunityId >>> ' + component.get('v.opportunityId'));
        console.log('@@>> opportunityId >>> ' + component.get('v.reschedule'));

        getAvailableAppointments.setParam('workOrderId', workOrderId);
        getAvailableAppointments.setParam('leadId', component.get('v.leadId'));
        getAvailableAppointments.setParam('opportunityId', component.get('v.opportunityId'));

        getAvailableAppointments.setParam('reschedule', component.get('v.reschedule'));
        getAvailableAppointments.setParam('bookNow', component.get('v.bookNow'));
        getAvailableAppointments.setCallback(this, function(response) {
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> initialize >> Start getConfigs callback');
            if(response.getState() == "SUCCESS") { 
                if(response.getReturnValue() != null && response.getReturnValue().success == 'true') {
                    let wrapperSlots = JSON.parse(response.getReturnValue().wrapperSlots);
                    console.log('wrapperSlots --> ' + response.getReturnValue());

                    component.set('v.wrapperSlots', wrapperSlots);  
    
                    let availableDates = [];
                    wrapperSlots.forEach(function(wrapperSlot) {
                        if(!availableDates.includes(wrapperSlot.eventDate)) availableDates.push(wrapperSlot.eventDate);
                    })
                    component.set('v.availableDates', availableDates);
                    _helper.showCalendarModal(component);
                } else {
                    /* if(response.getReturnValue().error.includes('No slots')) component.set('v.toastMessage', response.getReturnValue().error + ' - ' + $A.get("$Label.c.TA_NoSlotsError"));          
                    else component.set('v.toastMessage', response.getReturnValue().error); */
                    component.set('v.toastMessage', $A.get("$Label.c.TA_NoSlotsError"));
                    component.set('v.isError', true);
                    component.set('v.showCalendarModal', false);
                    component.set('v.showToastMessage', true);
                    component.set('v.isSpinnerVisible', false);
                    _helper.sendError(component);
                }

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.sendError(component);
                component.set('v.isSpinnerVisible', false);
            }  
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> initialize >> End getConfigs callback');
        });
        //_helper.fireToggleSpinnerEvent(component, true)
        component.set('v.isSpinnerVisible', true);
        $A.enqueueAction(getAvailableAppointments);
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> getAvailableAppointments >> End');
    },

    formatFullCalendarData : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> formatFullCalendarData >> Start');

        let jsonDataArray = [];
        let availableDates = component.get('v.availableDates');

        availableDates.forEach(function(availableDate) {
            let checkDate = false;
            jsonDataArray.forEach(function(jsonEvent) {
                if(jsonEvent.start == availableDate) {
                    checkDate = true;
                }
            });
            if(!checkDate) {
                jsonDataArray.push({
                    start:  availableDate,
                    end:    availableDate
                });
            }
        });
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> formatFullCalendarData >> Finish');
        return jsonDataArray;
    },

    loadDataToCalendar : function(component, data) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> Start');

        let _helper     = this;
        let currentDate = _helper.getCurrentDate();
        let calendarEl  = document.getElementById(component.get('v.calendarName'));
        let availableDates = component.get('v.availableDates');

        calendarEl.innerHTML = "";

        let calendar = new FullCalendar.Calendar(calendarEl, {
            plugins: ['interaction','dayGrid'],
            header: {
                left: 'prev,next',
                center: 'title',
                right: 'customTodayButton'
            },
            defaultDate: currentDate,
            navLinks: false,
            editable: false,
            eventLimit: true,
            events: data,
            height: 400,
            eventLimit: 1,

            dateClick : function(arg) {
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> dateClick >> Start');
                _helper.focusOnDate(component, arg.dateStr, arg.dayEl, availableDates);          
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> dateClick >> Finish');
            },

            eventRender : function(info) {
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> eventRender >> Start');
                info.el.innerHTML = '<div class="ta-event-point">&#9679;</div>';
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> eventRender >> Finish');
            },

            eventClick: function(arg) {
                console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> eventClick >> Start');
            }
        });

        calendar.render();
        component.set('v.isSpinnerVisible', false);

        console.log('TA_LCP224_BookAppointmentModal >> Helper >> loadDataToCalendar >> Finish');
    },

    focusOnDate : function(component, dateToFocus, domElement, availableDates) {

        let timeSlots = [];
        let wrapperSlots = component.get('v.wrapperSlots');

        availableDates.forEach(function(availableDate) {
            if(availableDate == dateToFocus) {
                wrapperSlots.forEach(function(wrapperSlot) {
                    if(wrapperSlot.eventDate == availableDate) {
                        timeSlots.push(wrapperSlot.timeSlotStartDisplay);
                    }
                });
            }
        });

        

        if($A.get("$Locale.language") == 'it') {
            let tmpDate = new Date(dateToFocus);
            component.set('v.selectedDateString', tmpDate.getDate() + '-' + (parseInt(tmpDate.getMonth()) + 1) + '-' + tmpDate.getFullYear());
        } else component.get('v.selectedDateString', dateToFocus);

        component.set('v.timeSlots', timeSlots);
        component.set('v.selectedDate', dateToFocus);
        component.set('v.showCalendarModal', false);
        component.set('v.isTimeSlotConfirmed', false);
        component.set('v.timeSlotSelected', null);
        component.set('v.showSlotSelectionModal', true);

        console.log('v.showSlotSelectionModal --> ' + component.get('v.showSlotSelectionModal'));
        console.log('v.selectedDate --> ' + component.get('v.selectedDate'));
    },

    getCurrentDate : function() {
        let today   = new Date();
        let year    = today.getFullYear();
        let month   = today.getMonth()+1;
        let day     = today.getDate();

        return year + '-' + (month<10 ? '0' : '') + month + '-' + (day<10 ? '0' : '') + day;       
    },

    showCalendarModal : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> showCalendarModal >> Start');
        //this.fireToggleSpinnerEvent(component, true)
        this.loadDataToCalendar(component, this.formatFullCalendarData(component));
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> showCalendarModal >> End');
    },

    timeSlotSelected : function(component, event) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> timeSlotSelected >> Start');
        let timeSlotSelected = event.currentTarget.id;
        let wrapperSlots = component.get('v.wrapperSlots');
        let selectedDate = component.get('v.selectedDate');
        let elementSelected = document.getElementById(timeSlotSelected);
        let oldElements = document.getElementsByClassName('ta-timeslot-box-selected');

        elementSelected.classList.remove("ta-timeslot-box");
        elementSelected.classList.add("ta-timeslot-box-selected");

        if(oldElements.length > 0) {
            let oldElementSelected = oldElements[0];
            oldElementSelected.classList.remove("ta-timeslot-box-selected");
            oldElementSelected.classList.add("ta-timeslot-box");
        }
        
        wrapperSlots.forEach(function(wrapperSlot) {
            if(wrapperSlot.eventDate == selectedDate && wrapperSlot.timeSlotStartDisplay == timeSlotSelected) {
                component.set('v.wrapperSlotSelected', wrapperSlot);
                component.set('v.timeSlotSelected', timeSlotSelected);
            }
        });

        console.log('TA_LCP224_BookAppointmentModal >> Helper >> timeSlotSelected >> End');
    },

    editDateSelected : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> editDateSelected >> Start');
        
        let selectedElements = document.getElementsByClassName('ta-timeslot-box-selected');
        if(selectedElements.length > 0) {
            let elementSelected = selectedElements[0];
            elementSelected.classList.remove("ta-timeslot-box-selected");
            elementSelected.classList.add("ta-timeslot-box");
        }
        
        component.set('v.timeSlotSelected', null);
        component.set('v.showCalendarModal', true);
        component.set('v.showSlotSelectionModal', false);

        console.log('TA_LCP224_BookAppointmentModal >> Helper >> editDateSelected >> End');
    },

    confirm : function(component, workOrderId) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> confirm >> Start');
        let _helper = this;
        let scheduleAppointment = component.get('c.scheduleAppointment');

        if(component.get('v.leadId') != null) {
            scheduleAppointment.setParam('recordId', component.get('v.leadId'));
        } else if(component.get('v.reschedule')) {
            scheduleAppointment.setParam('recordId', component.get('v.wrapperSlotSelected').servAppId);
        } else {
            if(component.get('v.wrapperSlotSelected') != null && component.get('v.wrapperSlotSelected').newWorkOrderId != null) {
                scheduleAppointment.setParam('recordId', component.get('v.wrapperSlotSelected').newWorkOrderId);
            } else {
                scheduleAppointment.setParam('recordId', workOrderId);
            }   
        }

        scheduleAppointment.setParam('wrapperSlotSelectedSerialized', JSON.stringify(component.get('v.wrapperSlotSelected')));
        scheduleAppointment.setParam('bookNow', component.get('v.bookNow'));
        scheduleAppointment.setParam('reschedule', component.get('v.reschedule'));
        scheduleAppointment.setCallback(this, function(response) {
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> scheduleAppointment >> Start getConfigs callback');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != null) {
                    if(response.getReturnValue().message == 'Operation completed successfully') {
                        component.set('v.communityBaseUrl', response.getReturnValue().communityBaseUrl);
                        component.set('v.showSlotSelectionModal', false);
                        if(!component.get("v.doConvertLead")){
                            component.set('v.showConfirmModal', true);
                        } else {
                            component.set("v.workOrderId", response.getReturnValue().workOrderId);
                            _helper.doConvertLead(component);
                        }
                    } else {
                        component.set('v.toastMessage', response.getReturnValue().message);
                        component.set('v.isError', true);
                        component.set('v.showSlotSelectionModal', false);
                        component.set('v.showToastMessage', true);
                        component.set('v.showBookAppointmentModal', false);
                        _helper.sendError(component);
                    }
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.sendError(component);
            }

            component.set('v.isSpinnerVisible', false);
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> scheduleAppointment >> End getConfigs callback');
        });

        $A.enqueueAction(scheduleAppointment);
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> confirm >> End');
    },

    closeModalEvt : function() {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> closeModalEvt >> Start');
        let closeModalEvt = $A.get("e.c:TA_LCE216_ModalManagement");
        closeModalEvt.setParam("show", false);
        closeModalEvt.setParam("type", 'close');
        closeModalEvt.fire();
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> closeModalEvt >> End');
    },

    redirectToPage : function(component, redirectParam, isPage) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> redirectToPage >> Start');
        console.log('@@>> redirectParam >> ' + redirectParam);
        let doConvertLead = component.get("v.doConvertLead");
        let doRedirect = component.get("v.doRedirect");
        if(doRedirect){
            if(!doConvertLead){
                //this.fireToggleSpinnerEvent(component, true);
                if(component.get("v.bookNow")){
                    redirectParam = component.get("v.workOrderId");
                    isPage = false;
                }
                component.set('v.isSpinnerVisible', true);
                let redirectUrl = component.get('v.communityBaseUrl') +'/';
                isPage ? redirectUrl = redirectUrl.concat('s/'.concat(redirectParam)) : redirectUrl = redirectUrl.concat(redirectParam);
                console.log('@@>> redirectUrl >> ' + redirectUrl);

                window.location.href = redirectUrl;
            }
        } else {
            component.set('v.showSlotSelectionModal', false);
            component.set('v.showConfirmModal', false);
            component.set('v.showCalendarModal', false);
            this.closeModalEvt();
        }
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> redirectToPage >> End');
    },

    doConvertLead : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> doConvertLead >> Start');

        let doConvertLeadEvt = component.getEvent("closeModalEvt");

        let params = {};
        params.workOrderId = component.get("v.workOrderId");

        doConvertLeadEvt.setParam("show", false);
        doConvertLeadEvt.setParam("type", 'doConvertLead');
        doConvertLeadEvt.setParam("params", params);
        doConvertLeadEvt.fire();

        console.log('TA_LCP224_BookAppointmentModal >> Helper >> doConvertLead >> End');
    },

    sendError : function(component) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> sendError >> Start');
        
        let sendErrorEvt = component.getEvent("sendErrorEvt");
        sendErrorEvt.setParams({
            'action' : 'sendError',
            'params' : {}
        });
        sendErrorEvt.fire();

        console.log('TA_LCP224_BookAppointmentModal >> Helper >> sendError >> End');
    },

    manageTime : function(component, event, helper) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> manageTime >> Start');
        let action = event.currentTarget.id;
        let durationTimeInHours = '';
        let durationTimeInMinutes = component.get("v.durationTimeInMinutes");
        let durationTimeInMinutesToAdd = component.get("v.durationTimeInMinutesToAdd");
        let durationType = '';
        let durationTime = 0;

        if(action != 'remove-time' || durationTimeInMinutes > durationTimeInMinutesToAdd) {
            if(action == 'add-time') {
                durationTimeInMinutes += durationTimeInMinutesToAdd;
            } else if(action == 'remove-time') {
                durationTimeInMinutes -= durationTimeInMinutesToAdd;
            }

            if(durationTimeInMinutes / 60 < 10) {
                durationTimeInHours += '0';
            }
            durationTimeInHours += Math.floor(durationTimeInMinutes / 60) + ':';

            if(durationTimeInMinutes % 60 != 0) {
                durationTimeInHours += '30';
            } else {
                durationTimeInHours += '00';
            }

            if(durationTimeInMinutes >= 60) {
                durationTime = durationTimeInMinutes / 60;
                durationType = 'Hours';
            } else {
                durationTime = durationTimeInMinutes;
                durationType = 'Minutes';
            }

            component.set("v.durationTimeInHours", durationTimeInHours);
            component.set("v.durationTimeInMinutes", durationTimeInMinutes);
            component.set("v.durationTime", durationTime);
            component.set("v.durationType", durationType);
        }
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> manageTime >> End');
    },

    saveDurationTime : function(component, event, helper) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> saveDurationTime >> Start');
        let durationTime = component.get('v.durationTime');
        let durationType = component.get('v.durationType');

        let action = component.get('c.updateServiceAppointmentDurationTime');
        action.setParams({
            "servAppId" : component.get('v.wrapperSlotSelected').servAppId,
            "durationTime" : durationTime,
            "durationType" : durationType
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> saveDurationTimeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                helper.confirm(component);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP224_BookAppointmentModal >> Helper >> saveDurationTimeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> saveDurationTime >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP224_BookAppointmentModal",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP224_BookAppointmentModal >> Helper >> fireToggleSpinnerEvent >> End');
    }
})