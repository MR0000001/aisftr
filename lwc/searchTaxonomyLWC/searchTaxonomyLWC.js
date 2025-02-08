import { LightningElement, track, api } from 'lwc';

export default class SearchTaxonomyLWC extends LightningElement {
    @track searchKey;
    @api clabel;
    @api disable;
    handleChange(event){
        /* eslint-disable no-console */
        //console.log('Search Event Started ');
        const searchKey = event.target.value;
        /* eslint-disable no-console */
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }
    @api Remove(){
        this.template.querySelector('form').reset();
    }
}