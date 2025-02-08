import { LightningElement, api, track } from 'lwc';
//LABELS
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';

export default class Paginator extends LightningElement {  
    @api records;
    @api pageSize;
    @api totalRecordsCount;
    @api totalPages;
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track recordsToDisplay;

    label = {
        first : 'First',
        previous : 'Previous',
        next : 'Next',
        last : 'Last',
        page,
        of
    }

	connectedCallback() {
        console.group('paginator connectedCallback');
        console.log('records: ', this.records);
        console.log('records != null: ', this.records  != null);
        console.log('records != undefined: ', this.records  != undefined);
        console.log('pageSize: ', this.pageSize);
        if(this.records != null && this.records.length > 0) {
            console.log('in if');
            console.log('records: ', this.records);
            console.log('records length: ', this.records.length);
            console.log('totalRecordsCount: ', this.totalRecordsCount);
            console.log('totalPages: ', this.totalPages);
		    this.displayRecordsPerPage();
        } else {
            this.page = 0;
            this.totalPages = 0;
            this.totalRecordsCount = 0;
        }
        console.groupEnd('paginator connectedCallback');
	}

    get showFirstButton() {
        if(this.page === 1 || this.page === 0) {  
            return true;  
        }  
        return false;  
    }  

    get showLastButton() {
        console.log('this.records.length: ', this.records.length);
        console.log('this.pageSize: ', this.pageSize);
        console.log('this.records.length / this.pageSize: ', this.records.length / this.pageSize);
        console.log('this.records.length / this.pageSize: ', Math.ceil(this.records.length / this.pageSize));
        console.log('this.page: ', this.page);

        if(this.records != null && Math.ceil(this.records.length / this.pageSize) === this.page) {  
            return true;  
        }  
        return false;  
    }

    renderedCallback() {
        console.group('renderedCallback');
        this.displayRecordsPerPage();
        console.groupEnd('renderedCallback');
    }

    handlePrevious() {
        console.group('handlePrevious');
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordsPerPage();
        }
        console.groupEnd('handlePrevious');
    }

    handleNext() {
        console.group('handleNext');
        console.log('handleNext ' + this.totalPages);
        console.log('handleNext ' + this.page);
        if((this.page < this.totalPages) && this.page !== this.totalPages){
            this.page = this.page + 1;
            this.displayRecordsPerPage();
        }
        console.groupEnd('handleNext');
    }

    handleFirst() {
        console.group('handleFirst');
        this.page = 1;
        this.displayRecordsPerPage();
        console.groupEnd('handleFirst');
    }

    handleLast() {
        console.group('handleLast');
        this.page = this.totalPages;
        this.displayRecordsPerPage();
        console.groupEnd('handleLast');
    }

    @api
    displayRecordsPerPage() {
        console.group('displayRecordsPerPage');
        console.log('page: ' + this.page);
        console.log('this.totalRecordsCount: ' + this.totalRecordsCount);
        this.page = ((this.page === 0 && this.totalRecordsCount > 0) || this.page > this.totalPages) ? 1 : this.page;
        this.startingRecord = ((this.page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * this.page);
        console.log('this.endingRecord before: ' + this.endingRecord);

        this.endingRecord = (this.endingRecord > this.totalRecordsCount) ? this.totalRecordsCount : this.endingRecord; 
        console.log('this.startingRecord before: ' + this.startingRecord);
        console.log('this.endingRecord after: ' + this.endingRecord);

        this.recordsToDisplay = this.records.slice(this.startingRecord, this.endingRecord);
                
        this.startingRecord = this.startingRecord + 1;
        console.log('this.startingRecord after: ' + this.startingRecord);
        console.log('recordsToDisplay ', this.recordsToDisplay);

        this.dispatchEvent(new CustomEvent('pagination', {
            detail: this.recordsToDisplay
        }));
        console.groupEnd('displayRecordsPerPage');
    }
}