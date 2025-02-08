/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@.fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TransferOrderChangeEvent – Change Event Trigger for INtegration User Stories.
*/
trigger Giic_TR_TransferOrderChangeEvent on gii__TransferOrder__ChangeEvent (after insert) {
   Giic_TR_TransferOrderChangeEvent_Handler.getReadyToIntegrateReceipt(Trigger.New);
 }