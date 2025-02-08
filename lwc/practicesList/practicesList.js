import { LightningElement, track, api } from 'lwc';  
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';
import serviceType from '@salesforce/label/c.SchoolConsultation_ServiceType';
import year from '@salesforce/label/c.SchoolConsultation_SchoolYear';
import name from '@salesforce/label/c.SchoolConsultation_Name';
import surname from '@salesforce/label/c.SchoolConsultation_Surname';
import birthday from '@salesforce/label/c.SchoolConsultation_Birthday';
import phone from '@salesforce/label/c.SchoolConsultation_Phone';
import status from '@salesforce/label/c.SchoolConsultation_Status';
import note from '@salesforce/label/c.SchoolConsultation_Note';
import msguid from '@salesforce/label/c.SchoolConsultation_msgUid';
 export default class RecordList extends LightningElement {  
   //@api accounts;
   @api practices;  
   @track error;  
   @api currentpage;  
   @api pagesize;  
   @api totalpages;
   @track searchKey;
   @track label = {
		page,
    of,
    year,
    serviceType,
    name,
    surname,
    birthday,
    phone,
    status,
    note,
    msguid
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