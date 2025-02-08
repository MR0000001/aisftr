/**
 * @description       :
 * @author            : Marco Lazzaroni (mlazzaroni@pic-informatica.it)
 * @group             :
 * @last modified on  : 03-05-2022
 * @last modified by  : Marco Lazzaroni (mlazzaroni@pic-informatica.it)
 **/
import { LightningElement, api, track } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport';

export default class CustomLookup extends LightningElement {
    @api strRecordId;
    @api strLabel;
    @api strRecordName;
    @api strObjectName;
    @api strSearchClause;
    @api strDisplayFields;
    @api strOutRecordId;
    @api strOutRecordName;

    fields = ['Name'];
    handleLookup = (event) => {
        let data = event.detail.data;
        if(data && data.record){
            // populate the selected record values in the correct output variables
            this.strOutRecordId = data.recordId;
            const fields = this.strDisplayFields.split(",");
            this.strOutRecordName = data.record[fields[0].trim()];
        }else{
            // clear the output variables
            this.strOutRecordId = "";
            this.strOutRecordName = "";
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('strOutRecordId', this.strOutRecordId));
        this.dispatchEvent(new FlowAttributeChangeEvent('strOutRecordName', this.strOutRecordName));
    }
}