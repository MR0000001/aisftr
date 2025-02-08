import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';
//LABELS
import genericError from '@salesforce/label/c.Generic_SomethingWrong';
import removalPlace from '@salesforce/label/c.autoreturn_removalPlace';
import placeCustody from '@salesforce/label/c.autoreturn_placeCustody';
import infoDeposit from '@salesforce/label/c.autoreturn_infoDeposit';
import cusodyArrivalDateTime from '@salesforce/label/c.autoreturn_cusodyArrivalDateTime';
import withdrawalDate from '@salesforce/label/c.autoreturn_withdrawalDate';
import licencePlate from '@salesforce/label/c.autoreturn_licencePlate';
import veicoloRitirato from '@salesforce/label/c.autoreturn_veicoloRitirato';
import vehicleModel from '@salesforce/label/c.autoreturn_vehicleModel';
import processType from '@salesforce/label/c.autoreturn_processType';
import lwcTitle from '@salesforce/label/c.autoreturn_lwcTitle';
import filters from '@salesforce/label/c.Filters';
import dateFrom from '@salesforce/label/c.Date_From';
import dateTo from '@salesforce/label/c.Date_To';
import reset from '@salesforce/label/c.Reset';
import search from '@salesforce/label/c.searchAccount_Search';
import fromGreaterThanTo from '@salesforce/label/c.Date_FromGreaterThanTo';
import fromDateOutOfRange from '@salesforce/label/c.Date_FromDateOutOfRange';
import toLessThanFrom from '@salesforce/label/c.Date_ToLessThanFrom';
import toDateOutOfRange from '@salesforce/label/c.Date_ToDateOutOfRange';
import genericIntegrationError from '@salesforce/label/c.Generic_Errors_IntegrationError';
import noVehiclesFound from '@salesforce/label/c.autoreturn_noVehiclesFound';
import defaultPageSize from '@salesforce/label/c.Generic_PageSize';
//FIELDS
import CASE_LICENCE_PLATE_FIELD from '@salesforce/schema/Case.License_plate__c';
//APEX
import getVehicles from '@salesforce/apex/AutoreturnController.getVehicles';
import getPageSize from '@salesforce/apex/AutoreturnController.getPageSize';

export default class Autoreturn extends LightningElement {
    @api recordId;
    @track pageSize = 1;
    @track licencePlate;
    @track vehicleHistory = [];
    @track vehicleHistoryFiltered = [];
    @track vehicleHistoryToDisplay = [];
    @track totalPages = 0;
    @track isSearchDisabled = true;
    @track isResetDisabled = true;
    @track isFromDateDisabled = false;
    @track isToDateDisabled = false;
    @track fromDate;
    @track toDate;
    @track isFromDateRangeMinMaxCorrect = true;
    @track isToDateRangeMinMaxCorrect = true;
    @track isDateRangeToFromError = false;
    @track fields = [CASE_LICENCE_PLATE_FIELD];
    @track loading = false;
    @track minDate;
    @track maxDate;
    @track minDateCmp;
    @track maxDateCmp;
    @track errorToDisplay;
    label = {
        errors : {
            genericError,
            genericIntegrationError,
            noVehiclesFound
        },
        defaultPageSize : parseInt(defaultPageSize),
        licencePlate,
        removalPlace,
        placeCustody,
        infoDeposit,
        cusodyArrivalDateTime,
        processType,
        vehicleModel,
        lwcTitle,
        filters: filters.toUpperCase(),
        withdrawalDate,
        dateFrom,
        dateTo,
        reset,
        search,
        fromGreaterThanTo,
        toLessThanFrom,
        fromDateOutOfRange,
        toDateOutOfRange,
        veicoloRitirato,

    };
    @track columns = [
        { label: this.label.removalPlace, fieldName: 'removalPlace', type: 'text', wrapText: true },
        { label: this.label.processType, fieldName: 'removalStatus', type: 'text', wrapText: true },
        { label: this.label.cusodyArrivalDateTime, fieldName: 'depositDate', type: 'text', wrapText: true },
        { label: this.label.infoDeposit, fieldName: 'depositInfo', type: 'text', wrapText: true },
        { label: this.label.placeCustody, fieldName: 'custodyPlace', type: 'text', wrapText: true },
        { label: this.label.withdrawalDate, fieldName: 'withdrawalDate', type: 'text', wrapText: true },
        { label: this.label.veicoloRitirato, fieldName: 'veicoloRitirato', type: 'text' },
    ];

    constructor() {
        console.group('constructor');
        super();
        this.getPageSize();
        console.groupEnd('constructor');
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        console.group('wire');
        if(error) {
            console.log("@@@ error recordId "+this.recordId);
            console.log(error);
            this.errorToDisplay = this.label.errors.genericError;
        } else if(data) {
            console.log("@@@ recordId "+this.recordId);
            console.log(data); 
            console.log('licence plate ' + data.fields.License_plate__c.value);
            this.licencePlate = data.fields.License_plate__c.value.toUpperCase();
            if(this.licencePlate) {
                console.log('the case has licence plate');
                this.loading = true;
                this.getVehicles(this.licencePlate);
            }
        }
        console.groupEnd('wire');
    }

    getPageSize() {
        console.group('getPageSize');
        getPageSize()
        .then(data => {
            console.log('data ', data);
            this.pageSize = data;
        }).catch(error => {
            console.log('error ', error);
            this.pageSize = this.label.defaultPageSize;
        }).finally(() => {
            console.log('this.pageSize ', this.pageSize);
            console.groupEnd('getPageSize');
        });
    }

    getVehicles(licencePlate) {
        console.group('getVehicles');
        getVehicles({licencePlate})
        .then(data => {
            console.log('data ', data);
            if(data && data.length) {
                console.log('vehicles exists ', data);
                data.sort((a, b) => Date.parse(a.depositDate) < Date.parse(b.depositDate));
                console.log('after sort: ', data);
                data.forEach(d => d.depositDate = d.depositDate.split('T')[0]);
                this.vehicleHistory = data;
                this.vehicleHistoryFiltered = data;
                this.vehicleHistoryToDisplay = data;
                this.setTotalPages();
                this.vehicleModel = data[0].model.toUpperCase();
                this.maxDate = Date.parse(data[0].depositDateFormatted);
                this.minDate = Date.parse(data.at(-1).depositDateFormatted);
                this.maxDateCmp = data[0].depositDateFormatted;
                this.minDateCmp = data.at(-1).depositDateFormatted;
                if(this.minDate == this.maxDate) {
                    console.log('disable filters');
                    this.disableAllFilters();
                }
                console.log(`Min date is ${this.minDate} and max date is ${this.maxDate}`);
            } else {
                this.errorToDisplay = data ? this.label.errors.noVehiclesFound : this.label.errors.genericIntegrationError;
            }
            console.log('vehicleHistory ', this.vehicleHistory);
            console.log('vehicleHistoryFiltered ', this.vehicleHistoryFiltered);
            console.log('vehicleHistoryToDisplay ', this.vehicleHistoryToDisplay);
        }).catch(error => {
            console.log('error ', error);
            this.errorToDisplay = error.body.message;
        }).finally(() => {
            this.loading = false;
            console.groupEnd('getVehicles');
        });
    }

    setTotalPages() {
        console.group('setTotalPages');
        this.totalPages = this.vehicleHistoryFiltered.length ? Math.ceil(this.vehicleHistoryFiltered.length / this.pageSize) : 0;
        console.log('this.totalPages: ', this.totalPages);
        console.groupEnd('setTotalPages');
    }

    disableAllFilters() {
        console.group('disableAllFilters');
        this.isSearchDisabled = true;
        this.isResetDisabled = true;
        this.isFromDateDisabled = true;
        this.isToDateDisabled = true;
        console.groupEnd('disableAllFilters');
    }

    handleFromDateChange(event) {
        console.group('handleFromDateChange');
        this.resetDateComponentErrors();
        this.fromDate = Date.parse(event.target.value);
        console.log('selected from date: ' + this.fromDate);
        console.log(this.fromDate >= this.minDate && this.fromDate <= this.maxDate);
        console.log(this.toDate);
        console.log(this.fromDate < this.toDate);
        this.dateErrorHandling(event.target.dataset.name);
        console.groupEnd('handleFromDateChange');
    }

    handleToDateChange(event) {
        console.group('handleToDateChange');
        this.resetDateComponentErrors();
        this.toDate = Date.parse(event.target.value);
        console.log('selected to date: ' + this.toDate);
        console.log(this.toDate >= this.minDate && this.toDate <= this.maxDate);
        console.log(this.fromDate);
        console.log(this.toDate > this.fromDate);
        this.dateErrorHandling(event.target.dataset.name);
        console.groupEnd('handleToDateChange');
    }

    resetDateComponentErrors() {
        console.group('resetDateComponentErrors');
        this.template.querySelectorAll(".DateFilters").forEach(cmp => {
            cmp.setCustomValidity('');
            cmp.reportValidity('');
        });
        console.groupEnd('resetDateComponentErrors');
    }

    setCustomErrorForDateCmp(dateCmpName, errorMsg) {
        let inputCmp = this.template.querySelector("[data-name="+dateCmpName+"]");
        inputCmp.setCustomValidity(errorMsg);
        inputCmp.reportValidity();
    }

    checkDateWithinRange(date, dateCmpName, errorMsg) {
        console.log('checkDateWithinRange');
        console.log('this.minDate: ', this.minDate);
        console.log('this.maxDate: ', this.maxDate);
        console.log(`${dateCmpName}: ${date}`);
        console.log('date < this.minDate ', date < this.minDate);
        console.log('date > this.maxDate ', date > this.maxDate);
        if(date && (date < this.minDate || date > this.maxDate)) {
            console.log('date populated but invalid');
            this.setCustomErrorForDateCmp(dateCmpName, errorMsg);
            return false;
        }
        return true;
    }

    checkFromToDatesValidity(fromDate, toDate, dateCmpName) {
        console.group('checkFromToDatesValidity');
        console.log(`from date is ${fromDate} and to date is ${toDate}. Is from date > to date?: ${fromDate > toDate}`);
        if(fromDate > toDate) {
            console.log('dateCmpName ', dateCmpName);
            let errorMsg = dateCmpName === 'fromDateCmp' ? this.label.fromGreaterThanTo : this.label.toLessThanFrom;
            console.log('errorMsg: ', errorMsg);
            this.setCustomErrorForDateCmp(dateCmpName, errorMsg);
        }
        console.groupEnd('checkFromToDatesValidity');
    }

    dateErrorHandling(dateCmpName) {
        console.group('dateErrorHandling');
        this.isFromDateRangeMinMaxCorrect = this.checkDateWithinRange(this.fromDate, 'fromDateCmp', this.label.fromDateOutOfRange);
        this.isToDateRangeMinMaxCorrect = this.checkDateWithinRange(this.toDate, 'toDateCmp', this.label.toDateOutOfRange);

        console.log('isFromDateRangeMinMaxCorrect: ', this.isFromDateRangeMinMaxCorrect);
        console.log('isToDateRangeMinMaxCorrect: ', this.isToDateRangeMinMaxCorrect);
        
        if(this.isFromDateRangeMinMaxCorrect && this.isToDateRangeMinMaxCorrect) {
            this.checkFromToDatesValidity(this.fromDate, this.toDate, dateCmpName);
        }

        this.handleDisableSearch();
        console.groupEnd('dateErrorHandling');
    }

    handleDisableSearch() {
        console.group('handleDisableSearch');
        console.log(`isToDateRangeMinMaxCorrect is ${this.isToDateRangeMinMaxCorrect}. isFromDateRangeMinMaxCorrect is ${this.isFromDateRangeMinMaxCorrect}. from date is ${this.fromDate}. to date is ${this.toDate}.`);
        console.log((!(this.isToDateRangeMinMaxCorrect && this.isFromDateRangeMinMaxCorrect) || this.fromDate > this.toDate || !(this.fromDate || this.toDate)));
        this.isSearchDisabled = (!(this.isToDateRangeMinMaxCorrect && this.isFromDateRangeMinMaxCorrect) || this.fromDate > this.toDate || !(this.fromDate || this.toDate));
        console.groupEnd('handleDisableSearch');
    }

    handleSearch() {
        console.group('handleSearch');
        this.vehicleHistoryFiltered = this.vehicleHistory;
        console.log('this.fromDate: ', this.fromDate);
        console.log('this.toDate: ', this.toDate);

        if(this.fromDate && this.toDate) {
            console.log('both dates populated');
            this.vehicleHistoryFiltered = this.vehicleHistoryFiltered.filter(vehicle => Date.parse(vehicle.depositDateFormatted) >= this.fromDate && Date.parse(vehicle.depositDateFormatted) <= this.toDate);
            this.isResetDisabled = false;
        } else if(this.fromDate) {
            console.log(' only from date populated');
            this.isResetDisabled = false;
            this.vehicleHistoryFiltered = this.vehicleHistoryFiltered.filter(vehicle => Date.parse(vehicle.depositDateFormatted) >= this.fromDate);
        } else {
            console.log('only to date populated');
            this.isResetDisabled = false;
            this.vehicleHistoryFiltered = this.vehicleHistoryFiltered.filter(vehicle => Date.parse(vehicle.depositDateFormatted) <= this.toDate);
        }

        this.setTotalPages();

        console.log('this.vehicleHistoryFiltered: ', this.vehicleHistoryFiltered);
        this.vehicleHistoryToDisplay = this.vehicleHistoryFiltered;
        console.groupEnd('handleSearch');
    }

    handleReset() {
        console.group('handleReset');
        this.resetDateComponent();
        this.toDate = undefined;
        this.fromDate = undefined;
        this.isSearchDisabled = true;
        this.isDateToError = false;
        this.isDateFromError = false;
        this.isToDateRangeMinMaxCorrect = true;
        this.isFromDateRangeMinMaxCorrect = true;
        this.isDateRangeToFromError = false;
        this.isResetDisabled = true;
        this.vehicleHistoryFiltered = this.vehicleHistory;
        this.vehicleHistoryToDisplay = this.vehicleHistory;
        this.setTotalPages();
        console.groupEnd('handleReset');
    }

    resetDateComponent() {
        console.group('resetDateComponent');
        this.template.querySelectorAll(".DateFilters").forEach(cmp => {
            cmp.value = '';
            cmp.setCustomValidity('');
            cmp.reportValidity('');
        });
        console.groupEnd('resetDateComponent');
    }

    handlePagination(event) {
        console.group('handlePagination');
        console.log('event.detail: ', event.detail);
        this.vehicleHistoryToDisplay = event.detail;
        console.groupEnd('handlePagination');
    }
}