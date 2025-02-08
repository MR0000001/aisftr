import { LightningElement,api,track } from 'lwc';
//LABELS
import walletsTtitle from '@salesforce/label/c.CitizenWallets_Wallets';
import walletsId from '@salesforce/label/c.CitizenWallets_WalletId';
import walletsName from '@salesforce/label/c.CitizenWallets_Name';
import walletsDescription from '@salesforce/label/c.CitizenWallets_Description';
import walletsType from '@salesforce/label/c.CitizenWallets_Type';
import walletsUnit from '@salesforce/label/c.CitizenWallets_Unit';
import walletsSupportTransfer from '@salesforce/label/c.CitizenWallets_SupportsTransfer';
import walletsBalance from '@salesforce/label/c.CitizenWallets_Balance';
import walletsRefId from '@salesforce/label/c.CitizenWallets_ReferenceId';
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';


export default class CitizenWalletsList extends LightningElement {
    @api wallets;
    @track walletsToDisplay;
    @track showListWallets;
    @track errorToDisplay;
    @track label = {
        walletsTtitle,
        walletsId,
        walletsName,
        walletsDescription,
        walletsType,
        walletsUnit,
        walletsSupportTransfer,
        walletsBalance,
        walletsRefId,
        of,
        page
    };

    @track page = 1; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @api pageSize; 
    @track totalRecordsCount = 0;
    @track totalPages = 0;

    @track columns = [
        { label: this.label.walletsId, fieldName: 'walletId', type: 'text', wrapText: true },
        { label: this.label.walletsName, fieldName: 'name', type: 'text', wrapText: true },
        { label: this.label.walletsDescription, fieldName: 'description', type: 'text', wrapText: true },
        { label: this.label.walletsType, fieldName: 'type', type: 'text', wrapText: true },
        { label: this.label.walletsUnit, fieldName: 'unit', type: 'text', wrapText: true },
        { label: this.label.walletsBalance, fieldName: 'balance', type: 'text', wrapText: true },
        { label: this.label.walletsRefId, fieldName: 'referenceId', type: 'text', wrapText: true }
    ];

    connectedCallback() {
        if(!this.wallets[0].errorMessage) {
            this.showListWallets = true;
            this.setInitialWalletsToDisplay();
            this.endingRecord = this.pageSize;
        } else {
            this.errorToDisplay = this.wallets[0].errorMessage;
            this.showListWallets = false;
        }
    }

    setInitialWalletsToDisplay() {
        this.setRecordsAndPagesCount(this.wallets);
        this.walletsToDisplay = this.wallets.slice(0, this.pageSize);
        console.log('this.totalRecordsCount ' + this.totalRecordsCount);
        console.log('this.totalPages ' + this.totalPages);
        console.log('this.walletsToDisplay ');
        console.log(this.walletsToDisplay);
    }
    
    setRecordsAndPagesCount(wallets) {
        this.totalRecordsCount = wallets.length;
        this.totalPages = Math.ceil(this.totalRecordsCount / this.pageSize);
    }

    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    handleNext() {
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
        this.startingRecord = ((page - 1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecordsCount) ? this.totalRecordsCount : this.endingRecord; 

        this.walletsToDisplay = this.wallets.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }
}