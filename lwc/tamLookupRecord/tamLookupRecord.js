/**
 * @description       : This component is used to display the selected record in the selected record section.
 * @author            : Amit Singh (https://sfdcpanther.com/custom-lookup-in-lightning-web-component/)
 * @group             :
 * @last modified on  : 03-05-2022
 * @last modified by  : Marco Lazzaroni (mlazzaroni@pic-informatica.it)
 **/
import { LightningElement, api } from 'lwc';

export default class tamLookupRecord extends LightningElement {

    @api iconUrl;
    @api objectLabel;
    @api record;
    @api index;
    @api showLabel = false;
    handleRemove = (event) => {
        event.preventDefault();
        const closeEvent = new CustomEvent('close', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {
                data : {
                    record     : undefined,
                    recordId   : undefined
                }
            }
        });
        this.dispatchEvent(closeEvent);
    }
}