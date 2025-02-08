import { LightningElement,api,track } from 'lwc';
//LABELS
import infoCardTitle from '@salesforce/label/c.CitizenWallets_InfoCard';
import cardStatus from '@salesforce/label/c.CitizenWallets_CardStatus';
import issueDate from '@salesforce/label/c.CitizenWallets_IssueDate';
import activationDate from '@salesforce/label/c.CitizenWallets_ActivationDate';
import expiryDate from '@salesforce/label/c.CitizenWallets_ExpiryDate';
import serialNumber from '@salesforce/label/c.CitizenWallets_SerialNumber';
import totalPoints from '@salesforce/label/c.CitizenWallets_TotalPoints';

export default class CitizenWalletInfoCard extends LightningElement {
    @api cardInformation;
    @track activationDate;
    @track expiryDate;
    @track serialNumber;
    @track issueDate;
    @track totalPoints;
    @track cardStatus;
    @track showInfoCard = false;
    @track errorToDisplay;
    @track label = {
        infoCardTitle,
        cardStatus,
        issueDate,
        activationDate,
        expiryDate,
        serialNumber,
        totalPoints
    }

    connectedCallback() {
        if(!this.cardInformation.errorMessage) {
            this.showInfoCard = true;
            this.activationDate = this.cardInformation.activationDate;
            this.expiryDate = this.cardInformation.expiryDate;
            this.issueDate = this.cardInformation.issueDate;
            this.serialNumber = this.cardInformation.serialNumber;
            this.cardStatus = this.cardInformation.cardStatus;
            this.totalPoints = this.cardInformation.totalPoints;
            console.log('this.totalPoints ' + this.totalPoints);
            console.log('this.cardInformation.totalPoints ' + this.cardInformation.totalPoints);
        } else {
            this.showInfoCard = true;
            this.errorToDisplay = this.transactionInformations[0].errorMessage;
        }
    }
}