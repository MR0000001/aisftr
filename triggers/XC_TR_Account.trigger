/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 28/08/2018
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Account – Trigger on Account
*/

trigger XC_TR_Account on Account (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_Account_Handler(), Trigger.operationType,constants.MDT_SKIP_ACCOUNT, 'SFM'); 	
}