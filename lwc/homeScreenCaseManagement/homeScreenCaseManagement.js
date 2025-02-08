import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//METHODS
import getAllRolesMetadata from '@salesforce/apex/CaseManagementController.getAllRolesMetadata';
import getActionsCaseManagement from '@salesforce/apex/CaseManagementController.getActionsCaseManagement';
//LABELS
import actions from '@salesforce/label/c.HomeScreenCaseManagement_Actions';
import action from '@salesforce/label/c.HomeScreenCaseManagement_Action';
import selectAction from '@salesforce/label/c.HomeScreenCaseManagement_SelectAction';
import attention from '@salesforce/label/c.HomeScreenCaseManagement_Attention';
import next from '@salesforce/label/c.HomeScreenCaseManagement_Next';
import role from '@salesforce/label/c.HomeScreenCaseManagement_Role';
export default class HomeScreenCaseManagement extends LightningElement {
    @api actions;
    @api originalUserRole;
    @track showRolesDropdown = false;
    @api roles = [];
    @api selectedAction;
    @api selectedRole;
    @track label = {
        actions,
        action,
        attention,
        selectAction,
        next,
        role
    };

    connectedCallback() {
        console.log('connectedCallback originalUserRole ' + this.originalUserRole);
        console.log('connectedCallback selectedRole ' + this.selectedRole);
        console.log('connectedCallback selectedAction ' + this.selectedAction);
        console.log(this.actions);
        if(this.originalUserRole == 'Super User') {
            console.log('in SuperUser');
            getAllRolesMetadata({})
            .then(data => {
                for(var key in data){
                    this.roles.push({value: key, label: data[key]});
                }
                this.showRolesDropdown = true;
            });
        }
        console.log('roles ', this.roles);
    }
    
    handleActionSelection(event){
        this.selectedAction = event.detail.value;
    }

    handleRoleSelection(event) {
        this.selectedRole = event.detail.value;
        if(this.originalUserRole == 'Super User') {
            console.log(this.selectedRole);
            console.log(this.originalUserRole);
            getActionsCaseManagement({userRole: this.selectedRole})
            .then(data =>{
                var actionsForHomeScreen = [];
                for(var key in data){
                    actionsForHomeScreen.push({value: key, label: data[key]});
                }
                this.actions = actionsForHomeScreen;
                console.log(this.actions);
            });
        }
    }

    handleNext(event) {
        console.log("@@@ next");
        if(this.selectedAction != null && this.selectedAction != ''){
            console.log("@@@ this.selectedAction "+this.selectedAction);
            var params = {
                selectedAction: this.selectedAction,
                userRole: this.selectedRole,
                actionsHomeScreen: this.actions,
                originalUserRole: this.originalUserRole
            };

            const selectedEvent = new CustomEvent('next', {
                detail : params
            });
            //dispatching the custom event
            this.dispatchEvent(selectedEvent);           
        } else {
            console.log("@@@ error");
            console.log("@@@ this.label.attention "+this.label.attention);
            console.log("@@@ this.label.selectAction "+this.label.selectAction);
            this.showToast(this.label.attention, this.label.selectAction, "error");
        }
    }

    showToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

}