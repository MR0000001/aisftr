import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//LABEL
import next from '@salesforce/label/c.Generic_Next';
import close from '@salesforce/label/c.Generic_Close';

export default class SearchLegalEntitiesInfoModal extends NavigationMixin(LightningElement) {
    @api messageToDisplay;
    @api hideButtons = false;
    @track label = {
        next,
        close
    }

    handleNavigation(event) {
        console.group('SearchLegalEntitiesInfoModal_handleNavigation');
        if(event.target.dataset.name == this.label.next) {
            const selectedEvent = new CustomEvent('redirecttoregistry');
            this.dispatchEvent(selectedEvent);
        } else {
            const selectedEvent = new CustomEvent('closemodal');
            this.dispatchEvent(selectedEvent);
        }
        console.groupEnd('SearchLegalEntitiesInfoModal_handleNavigation');
    }
}