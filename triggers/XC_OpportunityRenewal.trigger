/*------------------------------------------------------------
  Author      :  Lokesh Pokuri
  Trigger     :  XC_OpportunityRenewal
  Description :  This trigger is added as part of XC-8 on Opportunity object to auto populate the Renewed/Recovered to Opportunity with the old opportunty value
---------------------------------------------------------------*/
trigger XC_OpportunityRenewal on Opportunity (before insert) {
    String recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B Opportunity Italy').getRecordTypeId();
    for (Opportunity o : Trigger.new) {
        if(o.IsClone() && o.RecordTypeId == recid) {
            o.XC_Renewed_Recovered_to_Opportunity__c = o.getCloneSourceId();
            //System.debug('getCloneSourceId()is:'+o.getCloneSourceId());
   } 
  }
}