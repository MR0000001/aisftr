/**
 * @description       : This class is called from the XC_FL_SafetyCultureRequestDetailUpsertWallet and XC_FL_SafetyCultureRequestUpsertWallet flows
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 30-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_IN092_KPISafetyCultureUpsertWallet {
    private static final Integer CHUNK_SIZE = 1;

    public class FlowInputs{

        @InvocableVariable
        public String requestId; 
    }

    public class FlowOutputs{
        
        @InvocableVariable
        public String result;
    }

    /**
    * @description method to update wallets with Safety culture KPI.
    * @author pedro.danielalmeida@nttdata.com | 30-06-2022 
    * @param flowInputs 
    * @return List<FlowOutputs> 
    **/
    @InvocableMethod
    public static List<FlowOutputs> upsertWalletsWithSafetyCultureKPI(List<FlowInputs> flowInputs){
        FlowOutputs output = new FlowOutputs();
        List<FlowOutputs> results = new List<FlowOutputs>();

        if (!flowInputs.isEmpty()) {
            XC_KPISafetyCultureRequestDetail__c requestDetail;
            
            //try {
                Id recordId = flowInputs[0].requestId;
                
                if (String.valueOf(recordId.getSobjectType()) == 'XC_KPI_Safety_Culture_Request__c') {
                    //requestDetail = [SELECT Id,XC_Account__c,XC_SPs_Added__c FROM XC_KPISafetyCultureRequestDetail__c WHERE XC_KPI_Safety_Culture_Request__c = :recordId AND XC_Request_Status__c = 'To Be Applied'];
                    Database.executeBatch(new XC_BA008_KPISafetyCultureCalc(recordId), CHUNK_SIZE);
                } else if (String.valueOf(recordId.getSobjectType()) == 'XC_KPISafetyCultureRequestDetail__c') {
                    requestDetail = [SELECT Id,XC_Account__c,XC_SPs_Added__c, XC_Participation_Outcome__c, XC_Participation_Rate__c, XC_KPI_Safety_Culture_Request__r.XC_Safety_Culture_Event__c FROM XC_KPISafetyCultureRequestDetail__c WHERE Id = :recordId];
                    XC_BA008_KPISafetyCultureCalc.safetyCultureApplyKPI(requestDetail);
                }
                 
    	}
        output.result = 'Your request has been processed.';
        results.add(output);
        return results;
	}
}