({
    initialize : function(component, isRefresh) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> initialize >> Start');
        let _helper = this;
        let action = component.get("c.initialize");
        action.setCallback(this, function (response) {
            console.log('TA_LCP200_AppointmentCalendar >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.infoBag', JSON.parse(response.getReturnValue()));
                _helper.loadDataToCalendar(component, _helper.formatFullCalendarData(component));
                _helper.manageServiceAppointments(component, component.get('v.infoBag'));
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP200_AppointmentCalendar >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        if(isRefresh) {
            component.set('v.isSpinnerVisible', true);
        }
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> initialize >> End');
    },

    formatFullCalendarData : function(component) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> formatFullCalendarData >> Start');
        let jsonDataArray = [];
        let infoBag = component.get('v.infoBag');

        if(infoBag != null && infoBag.serviceAppointment != null) {
            infoBag.serviceAppointment.forEach(function(servAppWrapper) {
                let checkDate = false;
                jsonDataArray.forEach(function(jsonEvent) {
                    if(jsonEvent.start == servAppWrapper.schedStartDate) {
                        checkDate = true;
                    }
                });
                if(!checkDate) {
                    jsonDataArray.push({
                        start : servAppWrapper.schedStartDate,
                        end : servAppWrapper.schedStartDate
                    });
                }
            });
        }
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> formatFullCalendarData >> End');
        return jsonDataArray;
    },

    loadDataToCalendar : function(component, data) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> Start');

        let _helper = this;
        let currentDate = _helper.getCurrentDate();
        let calendarEl = document.getElementById('calendar');

        calendarEl.innerHTML = "";

        let calendar = new FullCalendar.Calendar(calendarEl, {
            plugins: ['interaction','dayGrid'],
            locale : 'it',
            header : {
                left : 'prev,next',
                center : 'title',
                right : 'customTodayButton'
            },
            customButtons : {
                customTodayButton : {text : $A.get("$Label.c.TA_Today")}
            },
            defaultDate: currentDate,
            navLinks: false,
            editable: false,
            eventLimit: true,
            events: data,
            height: 400,
            eventLimit: 1,

            dateClick : function(arg) {
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> dateClick >> Start');
                _helper.focusOnDate(component, arg.dateStr, arg.dayEl);
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> dateClick >> End');
            },

            eventRender : function(info) {
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> eventRender >> Start');
                info.el.innerHTML = '<div class="xc-event-point">&#9679;</div>';
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> eventRender >> End');
            },

            eventClick: function(arg) {
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> eventClick >> Start');
                console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> eventClick >> End');
            }
        });

        calendar.render();
        this.focusOnDate(component, this.getCurrentDate(), $("[data-date='" + currentDate + "']")[0]);

        document.getElementsByClassName('fc-customTodayButton-button')[0].addEventListener('click', function() {
            //Remove cookie
            var cookieName = "selectedDate";
            _helper.setCookie(cookieName, "", -1);
            let currentDate = _helper.getCurrentDate();
            calendar.today();
            _helper.focusOnDate(component, currentDate, $("[data-date='" + currentDate + "']")[0]);
        });

        component.set('v.isInitialized', true);
        component.set('v.isSpinnerVisible', false);
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> loadDataToCalendar >> End');
    },

    cardClick : function(component, event, helper) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> cardClick >> Start');
        helper.redirectToWorkOrder(component, event.currentTarget.dataset.id);
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> cardClick >> End');
    },

    redirectToWorkOrder : function(component, objectId) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> redirectToWorkOrder >> Start');
        component.set("v.isSpinnerVisible", true);
        let redirectUrl = component.get('v.infoBag.communityBaseURL') + '/' + objectId;
        window.location.href = redirectUrl;
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> redirectToWorkOrder >> End');
    },

    getCurrentDate : function() {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> getCurrentDate >> Start');
        //Check cookie
        var cookieName = "selectedDate";
        var cvalue = this.getCookie(cookieName);
        var dateToReturn;
        if (cvalue != "" && cvalue != null) {
            dateToReturn = cvalue;
        } else {
            let today = new Date();
            let year = today.getFullYear();
            let month = today.getMonth() + 1;
            let day = today.getDate();

            dateToReturn = year + '-' + (month<10 ? '0' : '') + month + '-' + (day<10 ? '0' : '') + day;
        }
        console.log(">_> dateToReturn : " + dateToReturn);
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> getCurrentDate >> End');
        return dateToReturn;
    },

    focusOnDate : function(component, dateToFocus, domElement) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> focusOnDate >> Start');
        let days = document.querySelectorAll(".selectedDate");
        let dailyAppointments = [];
        let infoBag = component.get('v.infoBag');

        //Set cookie
        var cookieName = "selectedDate";
        this.setCookie(cookieName, dateToFocus, null);

        if(days != null) {
            days.forEach(function(day) {
                day.classList.remove("selectedDate");
            });
        }

        if(domElement != null) domElement.classList.add("selectedDate");

        if(infoBag != null && infoBag.serviceAppointment != null) {
            infoBag.serviceAppointment.forEach(function(element) {
                if(element.schedStartDate == dateToFocus) {
                    dailyAppointments.push(element);
                }
            });
        }

        component.set("v.dailyAppointments", dailyAppointments);
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> focusOnDate >> End');
    },

    manageServiceAppointments : function(component, infoBag) {
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> manageServiceAppointments >> Start');
        let _helper = this;

        if(infoBag != null && infoBag.serviceAppointment != null) {
            infoBag.serviceAppointment.forEach(function(sa) {
                if(sa.customerName) {
                    if(sa.customerName.length > 30) sa.customerName = sa.customerName.substr(0, 30) + '..';
                }
                if(sa.toLabelWorkTypeLabel) {
                    if(sa.toLabelWorkTypeLabel.length > 31) sa.toLabelWorkTypeLabel = sa.toLabelWorkTypeLabel.substr(0, 30) + '..';
                }
                if(sa.address) {
                    if(sa.address.length > 36) sa.address = sa.address.substr(0, 35) + '..';
                }
                if(sa.duration) {
                    if(sa.durationType == 'Hours') {
                        sa.duration = _helper.formatDuration(sa.duration);
                    } else if(sa.durationType == 'Minutes') {
                        sa.duration = sa.duration.substr(0,2);
                    }       
                }
            });
            component.set('v.infoBag', infoBag);
        }
        console.log('TA_LCP200_AppointmentCalendar >> Helper >> manageServiceAppointments >> End');
    },

    formatDuration : function(decimalToFormat) {
        let decimalTime = parseFloat(decimalToFormat);
        decimalTime = decimalTime * 60 * 60;

        let hours = Math.floor((decimalTime / (60 * 60)));
        decimalTime = decimalTime - (hours * 60 * 60);

        let minutes = Math.floor((decimalTime / 60));
        decimalTime = decimalTime - (minutes * 60);

        if(minutes < 10) {
            minutes = "0" + minutes;
        }
        return "" + hours + ":" + minutes;
    }
})