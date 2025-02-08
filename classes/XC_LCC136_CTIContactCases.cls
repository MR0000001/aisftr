/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 22-07-2019
*@Description: Component controller for XC_LCP136_CTIContactCases
**/
public with sharing class XC_LCC136_CTIContactCases {

    public class WrapperCTICases{
        @AuraEnabled
        public List<Case> casesMatch;
        @AuraEnabled
        public Integer totalSize;
    }

    /**
    *@Author: Francesco Imperioli fimperioli@deloitte.it
    *@Date creation : 22-07-2019
    *@Description retrieves cases related to a particular contact with pagination management
    **/
    @AuraEnabled
    public static WrapperCTICases retrieveCasePage(String pageSize,String pageNumber,String contactId){

        WrapperCTICases result= new WrapperCTICases();
        result.casesMatch = new List<Case>();
        result.totalSize = 0;

        if(contactId!=null){

        
        
        Integer psize = Integer.valueOf(pageSize);
        Integer pnumber = Integer.valueOf(pageNumber)-1;

        AggregateResult [] caseCount = [SELECT COUNT(Id)countC FROM Case WHERE ContactId=:contactId];
        Integer totalRecords = Integer.valueOf(caseCount[0].get('countC'));


        result.casesMatch = [SELECT Id,CaseNumber,toLabel(Reason),toLabel(Status),CreatedDate FROM Case WHERE ContactId = : contactId ORDER BY CreatedDate DESC LIMIT :psize OFFSET :(psize*pnumber)];
        result.totalSize = totalRecords;

        }

        return result;

    }


}