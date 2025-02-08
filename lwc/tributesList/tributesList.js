import { LightningElement, track, api } from 'lwc';  
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';
import year from '@salesforce/label/c.TributesConsultation_YearHeader';
import tribute from '@salesforce/label/c.TributesConsultation_TributeHeader';
import description from '@salesforce/label/c.TributesConsultation_Description';
import issueDate from '@salesforce/label/c.TributesConsultation_IssueDate';
import expirationDate from '@salesforce/label/c.TributesConsultation_ExpirationDate';
import amountDate from '@salesforce/label/c.TributesConsultation_AmountDue';
import amountReduced from '@salesforce/label/c.TributesConsultation_AmountDueReduced';
import amountDueIncreased from '@salesforce/label/c.TributesConsultation_AmountDueIncreased';
import amountPaid from '@salesforce/label/c.TributesConsultation_AmountPaid';
import amountPaidInstallment from '@salesforce/label/c.TributesConsultation_AmountPaidInstallment';
import paymentId from '@salesforce/label/c.TributesConsultation_PaymentId';
import paymentDate from '@salesforce/label/c.TributesConsultation_PaymentDate';
import paymentIntermediary from '@salesforce/label/c.TributesConsultation_PaymentIntermediary';
 export default class RecordList extends LightningElement {  
   //@api accounts;
   @api tributes;  
   @track error;  
   @api currentpage;  
   @api pagesize;  
   @api totalpages;
   @api showadditionalparameters = false;
   @api tributesYear;
   @api tributesTypology;
   @track searchKey;
   @track label = {
		page,
    of,
    year,
    tribute,
    description,
    issueDate,
    expirationDate,
    amountDate,
    amountReduced,
    amountDueIncreased,
    amountPaid,
    amountPaidInstallment,
    paymentId,
    paymentDate,
    paymentIntermediary
    };  
   totalpages;  
   localCurrentPage = null;  
   isSearchChangeExecuted = false;  
   
   renderedCallback() {  
    this.isSearchChangeExecuted = true;  
    this.localCurrentPage = this.currentpage; 
    //console.log('@@@ this.accounts '+this.accounts);
    const event = new CustomEvent('recordsload', {  
      detail: this.totalrecords  
    }); 
   }
 }