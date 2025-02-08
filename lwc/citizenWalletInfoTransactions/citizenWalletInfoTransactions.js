import { LightningElement,api,track } from 'lwc';
//LABEL
import infoTransactionsTitle from '@salesforce/label/c.CitizenWallets_InfoTransactions';
import dateFrom from '@salesforce/label/c.Date_From';
import dateTo from '@salesforce/label/c.Date_To';
import transactionId from '@salesforce/label/c.CitizenWallets_TransactionId';
import transactionValue from '@salesforce/label/c.CitizenWallets_Value';
import transactionAmount from '@salesforce/label/c.CitizenWallets_Amount';
import transactionDate from '@salesforce/label/c.CitizenWallets_TransactionDate';
import transactionNotes from '@salesforce/label/c.CitizenWallets_Notes';
import transactionStatus from '@salesforce/label/c.CitizenWallets_TransactionStatus';
import transactionType from '@salesforce/label/c.CitizenWallets_TransactionType';
import transactionAuthCode from '@salesforce/label/c.CitizenWallets_AuthorizationCode';
import transactionBankId from '@salesforce/label/c.CitizenWallets_PiggyBankID';
import transactionBankName from '@salesforce/label/c.CitizenWallets_PiggyBankName';
import transactionBankDescription from '@salesforce/label/c.CitizenWallets_PiggyBankDescription';
import transactionReceipt from '@salesforce/label/c.CitizenWallets_Receipt';
import transactionExtTxId from '@salesforce/label/c.CitizenWallets_ExternalTxID';
import transactionShop from '@salesforce/label/c.CitizenWallets_Shop';
import transactionTerminal from '@salesforce/label/c.CitizenWallets_Terminal';
import transactionCorrelationRefId from '@salesforce/label/c.CitizenWallets_CorrelationReferenceId';
import transactionRefId from '@salesforce/label/c.CitizenWallets_ReferenceId';
import selectPartner from '@salesforce/label/c.CitizenWallets_SelectPartner';
import partners from '@salesforce/label/c.CitizenWallets_Partners';
import daysFilters from '@salesforce/label/c.CitizenWallets_DaysFilters';
import dateLessThan30 from '@salesforce/label/c.CitizenWallets_DateLessThan30';
import dateLessThan60 from '@salesforce/label/c.CitizenWallets_DateLessThan60';
import dateLessThan90 from '@salesforce/label/c.CitizenWallets_DateLessThan90';
import filters from '@salesforce/label/c.Filters';
import reset from '@salesforce/label/c.Reset';
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';
import fromGreaterThanTo from '@salesforce/label/c.Date_FromGreaterThanTo';
import toLessThanFrom from '@salesforce/label/c.Date_ToLessThanFrom';
import daysNone from '@salesforce/label/c.CitizenWallets_DaysNone';
import partnersNone from '@salesforce/label/c.CitizenWallets_PartnersNone';
import search from '@salesforce/label/c.searchAccount_Search';

export default class CitizenWalletInfoTransactions extends LightningElement {
    @api minDate;
    @api maxDate;
    @api partnersList;
    @api transactionInformations;
    @track transactionsToDisplay = [];
    @track transactionsFiltered = [];
    @track fromDate;
    @track toDate;
    @track showInfoTranscation = false
    @track errorToDisplay;
    @track partners = [];
    @track selectedPartner;
    @track sortedBy = 'transactionId';
    @track sortedDirection = 'desc';
    @track selectedDaysBefore;
    @track dateString = '';
    @track isFiltered;
    @track isDisabledSearch = true;
    @track isFromDateRangeMinMaxError = false;
    @track isToDateRangeMinMaxError = false;
    @track isDateRangeToFromError = false;
    @track isFromDateSelected = false;
    @track isToDateSelected = false;
    @track label = {
        infoTransactionsTitle,
        dateFrom,
        dateTo,
        transactionId,
        transactionValue,
        transactionAmount,
        transactionDate,
        transactionNotes,
        transactionStatus,
        transactionType,
        transactionAuthCode,
        transactionBankId,
        transactionBankName,
        transactionBankDescription,
        transactionReceipt,
        transactionExtTxId,
        transactionShop,
        transactionTerminal,
        transactionCorrelationRefId,
        transactionRefId,
        selectPartner,
        partners,
        filters,
        daysFilters,
        dateLessThan30,
        dateLessThan60,
        dateLessThan90,
        reset,
        page,
        of,
        fromGreaterThanTo,
        toLessThanFrom,
        daysNone,
        partnersNone,
        search
    };

    @track page = 1; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @api pageSize; 
    @track totalRecordsCount = 0;
    @track totalPages = 0;

    @track lessThanDays = [
        {label : this.label.daysNone, value : this.label.daysNone},
        {label : this.label.dateLessThan30, value : this.label.dateLessThan30},
        {label : this.label.dateLessThan60, value : this.label.dateLessThan60},
        {label : this.label.dateLessThan90, value : this.label.dateLessThan90},
    ];

    @track columns = [
        { label: this.label.transactionId, fieldName: 'transactionId', type: 'text', wrapText: true },
        { label: this.label.transactionValue, fieldName: 'value', type: 'text', wrapText: true },
        { label: this.label.transactionAmount, fieldName: 'amount', type: 'text', wrapText: true },
        { label: this.label.transactionDate, fieldName: 'transactionDateString', type: 'text', wrapText: true },
        { label: this.label.transactionBankName, fieldName: 'piggyBankName', type: 'text', wrapText: true },
        { label: this.label.transactionBankDescription, fieldName: 'piggyBankDescription', type: 'text', wrapText: true },
        { label: this.label.transactionShop, fieldName: 'shop', type: 'text', wrapText: true },
        { label: this.label.transactionTerminal, fieldName: 'terminal', type: 'text', wrapText: true }
    ];

    connectedCallback() {
        if(!this.transactionInformations[0].errorMessage) {
            this.selectedPartner = this.label.partnersNone;
            this.selectedDaysBefore = this.label.daysNone;
            this.showInfoTranscation = true;
            this.setInitialTransactionsToDisplay();
            this.endingRecord = this.pageSize;
            this.setPartners();
        } else {
            this.showInfoTranscation = false;
            this.errorToDisplay = this.transactionInformations[0].errorMessage;
        }
    }

    setInitialTransactionsToDisplay() {
        this.transactionsFiltered = this.transactionInformations;
        this.setRecordsAndPagesCount(this.transactionInformations);
        this.transactionsToDisplay = this.transactionInformations.slice(0, this.pageSize);
        console.log('this.totalRecordsCount ' + this.totalRecordsCount);
        console.log('this.totalPages ' + this.totalPages);
        console.log('this.transactionsToDisplay ');
        console.log(this.transactionsToDisplay);
    }

    setPartners() {
        this.partners = [{ label : this.label.partnersNone, value : this.label.partnersNone}];
        for(let elem of this.partnersList) {
            console.log(elem);
            const option = {
                label: elem,
                value: elem
            };
            this.partners = [...this.partners, option];
        }
    }

    setRecordsAndPagesCount(transactions) {
        this.totalRecordsCount = transactions.length;
        this.totalPages = Math.ceil(this.totalRecordsCount / this.pageSize);

        console.log('this.totalRecordsCount ' + this.totalRecordsCount);
        console.log('this.totalPages ' + this.totalPages);
    }

    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    handleNext() {
        console.log('handleNext ' + this.totalPages);
        console.log('handleNext ' + this.page);
        if((this.page < this.totalPages) && this.page !== this.totalPages){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }             
    }

    handleFirst() {
        this.page = 1;
        this.displayRecordPerPage(this.page);
    }

    handleLast() {
        this.page = this.totalPages;
        this.displayRecordPerPage(this.page);
    }

    displayRecordPerPage(page) {
        console.log('page: ' + page);
        console.log('this.totalRecordsCount: ' + this.totalRecordsCount);
        page = (page === 0 && this.totalRecordsCount != 0) ? 1 : page;
        this.startingRecord = ((page - 1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        console.log('this.endingRecord before: ' + this.endingRecord);

        this.endingRecord = (this.endingRecord > this.totalRecordsCount) ? this.totalRecordsCount : this.endingRecord; 
        console.log('this.startingRecord before: ' + this.startingRecord);
        console.log('this.endingRecord after: ' + this.endingRecord);

        if(this.isFiltered) {
            this.transactionsToDisplay = this.transactionsFiltered.slice(this.startingRecord, this.endingRecord);
        } else {
            this.transactionsToDisplay = this.transactionInformations.slice(this.startingRecord, this.endingRecord);
        }

        this.page = page;
        this.startingRecord = this.startingRecord + 1;
        console.log('this.startingRecord after: ' + this.startingRecord);
    }

    handleSearch() {
        this.isFiltered = false;
        this.transactionsFiltered = this.transactionInformations;
        if(this.fromDate) {
            console.log('filter from date');
            this.isFiltered = true;
            this.transactionsFiltered = this.transactionsFiltered.filter(transaction => transaction.transactionDate >= this.fromDate);
        }
        if(this.toDate) {
            console.log('filter to date');
            this.isFiltered = true;
            this.transactionsFiltered = this.transactionsFiltered.filter(transaction => transaction.transactionDate <= this.toDate);
        }
        if(this.selectedPartner != this.label.partnersNone) {
            console.log('filter parters');
            this.isFiltered = true;
            this.transactionsFiltered = this.transactionsFiltered.filter(transaction => transaction.piggyBankName == this.selectedPartner);
        }
        if(this.dateString) {
            console.log('filter days');
            this.isFiltered = true;
            this.transactionsFiltered = this.transactionsFiltered.filter(transaction => Date.parse(transaction.transactionDate) >= Date.parse(this.dateString));
        }

        if(this.isFiltered) {
            console.log('this.page hasBeenFiltered ' + this.page);
            this.page = 1;
            this.setRecordsAndPagesCount(this.transactionsFiltered);
            this.displayRecordPerPage(this.page);
        }

        if(this.isFiltered && this.transactionsFiltered.length == 0) {
            console.log('this.page length ' + this.page);
            console.log('this.transactionsFiltered.length ' + this.transactionsFiltered.length);
            this.page = 0;
        }
    }

    handleFromDateChange(event) {
        this.resetDateComponentErrors();
        this.fromDate = event.target.value;
        this.isFromDateSelected = true;
        console.group('handleFromDateChange');
        console.log('selected from date: ' + this.fromDate);
        console.log(this.fromDate >= this.minDate && this.fromDate <= this.maxDate);
        console.log(this.toDate);
        console.log(this.fromDate < this.toDate);
        console.groupEnd('handleFromDateChange');
        this.dateErrorHandling();        
    }

    handleToDateChange(event) {
        this.resetDateComponentErrors();
        this.toDate = event.target.value;
        this.isToDateSelected = true;
        console.group('handleToDateChange');
        console.log('selected to date: ' + this.toDate)
        console.log(this.toDate >= this.minDate && this.toDate <= this.maxDate);
        console.log(this.fromDate);
        console.log(this.toDate > this.fromDate);
        console.groupEnd('handleToDateChange');
        this.dateErrorHandling();
    }

    resetDateComponentErrors() {
        this.template.querySelectorAll(".DateFilters").forEach(cmp => {
            cmp.setCustomValidity('');
            cmp.reportValidity('');
        });
    }

    dateErrorHandling() {
        if(this.fromDate) {
            this.isFromDateRangeMinMaxError = !(this.fromDate >= this.minDate && this.fromDate <= this.maxDate);
            console.log('this.isFromDateRangeMinMaxError ' + this.isFromDateRangeMinMaxError);
        } else {
            this.isFromDateRangeMinMaxError = false;
        }

        if(this.toDate) {
            this.isToDateRangeMinMaxError = !(this.toDate >= this.minDate && this.toDate <= this.maxDate);
            console.log('this.isToDateRangeMinMaxError ' + this.isToDateRangeMinMaxError);
        } else {
            this.isToDateRangeMinMaxError = false;
        }

        if(!(this.isFromDateRangeMinMaxError || this.isToDateRangeMinMaxError) && this.fromDate && this.toDate) {
            this.isDateRangeToFromError = (this.fromDate > this.toDate);
            if(this.isFromDateSelected && this.isDateRangeToFromError) {
                this.setCustomErrorForDateCmp('.fromDateCmp', this.label.fromGreaterThanTo);
            }

            if(this.isToDateSelected && this.isDateRangeToFromError) {
                this.setCustomErrorForDateCmp('.toDateCmp', this.label.toLessThanFrom);
            }
        } else {
            this.isDateRangeToFromError = false;
        }
        
        this.isFromDateSelected = false;
        this.isToDateSelected = false;
        this.handleDisableSearch();
    }

    setCustomErrorForDateCmp(cmp, errorMsg) {
        let inputCmp = this.template.querySelector(cmp);
        inputCmp.setCustomValidity(errorMsg);
        inputCmp.reportValidity();
    }

    handlePartnersChange(event) {
        this.selectedPartner = event.target.value;
        console.log('selected partner: ' + this.selectedPartner);
        this.handleDisableSearch();
    }

    handleDaysChange(event) {
        this.selectedDaysBefore = event.target.value;
        console.log('this.selectedDaysBefore');
        console.log(this.selectedDaysBefore);
        if(this.selectedDaysBefore != this.label.daysNone) {
            let date = new Date();
            date.setDate(date.getDate() - Number(this.selectedDaysBefore));
            this.dateString = date.toISOString().split('T')[0];
        } else {
            this.dateString = '';
        }
        this.handleDisableSearch();
    }

    handleDisableSearch() {
        console.group('handleDisableSearch');
        console.log('handleDisableSearch');
        console.log((this.isToDateRangeMinMaxError || this.isFromDateRangeMinMaxError || this.isDateRangeToFromError) || !(Boolean(this.fromDate) || Boolean(this.toDate) || Boolean(this.dateString) || (Boolean(this.selectedPartner) && this.selectedPartner != this.label.partnersNone)));
        console.groupEnd('handleDisableSearch');
        this.isDisabledSearch = (this.isToDateRangeMinMaxError || this.isFromDateRangeMinMaxError || this.isDateRangeToFromError) || !(Boolean(this.fromDate) || Boolean(this.toDate) || Boolean(this.dateString) || (Boolean(this.selectedPartner) && this.selectedPartner != this.label.partnersNone));
    }

    handleReset() {
        this.setInitialTransactionsToDisplay();
        this.resetDateComponent();
        this.isFiltered = false;
        this.toDate = null;
        this.fromDate = null; 
        this.selectedPartner = this.label.partnersNone; 
        this.selectedDaysBefore = this.label.daysNone; 
        this.dateString = '';
        this.isDisabledSearch = true;
        this.page = 1;
        this.isDateToError = false;
        this.isDateFromError = false;
        this.isToDateRangeMinMaxError = false;
        this.isFromDateRangeMinMaxError = false;
        this.isDateRangeToFromError = false;
    }

    resetDateComponent() {
        this.template.querySelectorAll(".DateFilters").forEach(cmp => {
            cmp.value = '';
            cmp.setCustomValidity('');
            cmp.reportValidity('');
        });
    }

    updateColumnSorting(event) {
        let sortedBy = event.detail.fieldName;
        let sortedDirection = event.detail.sortDirection;
        //this.sortData(sortedBy, sortedDirection);
        /*console.log('this.sortedBy');
        console.log(this.sortedBy);
        console.log('this.sortedDirection');
        console.log(this.sortedDirection);
        console.log('transactionsToDisplay');
        console.log(this.transactionsToDisplay);
        let parseData = JSON.parse(JSON.stringify(this.transactionsToDisplay));
        console.log(parseData);
        parseData.sort((a, b) => {
            console.log(a[this.sortedBy]);
            console.log(b[this.sortedBy]);
            console.log(a[this.sortedBy] > b[this.sortedBy]);
            if(a[this.sortedBy] > b[this.sortedBy]) {
                console.log('1');
                return 1;
            }
            if(b[this.sortedBy] > a[this.sortedBy]) {
                console.log('-1');
                return -1;
            } 

            return 0;
        });

        console.log(parseData);
        this.transactionsToDisplay = parseData;
        */
    }

    sortData(sortby, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.transactionInformations));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[sortby];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.transactionsToDisplay = parseData;

    }
}