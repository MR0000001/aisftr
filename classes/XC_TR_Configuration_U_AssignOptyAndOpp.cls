/**
* @author Elisa Caldini - elisa.caldini@accenture.com
* @date Creation 11/03/2022
* @description XC_TR_Configuration_U_AssignOptyAndOpp – Class to assign owner to opportunity and configuration type opty in case of segment B2B/G legalEntity EnelXItalia,EnelSole in businessLine eCity
*/

public with sharing class XC_TR_Configuration_U_AssignOptyAndOpp {
    
    /**
     * @description  assign Owner to configuration type Opty and Opportunity before approval process (use method in trigger of Configuration Item Attribute on AfterInsert)
     *
     * @param listNew the list new of NE__Order_Item_Attribute__c
     * 
     */

    public static void executeAssignOwnerOppConfPreAppr(List<NE__Order_Item_Attribute__c> listNew){
      
		List<Id> configurationItemAttrListId = XC_UTIL_Sobject.getListFieldValues(listNew, 'Id');
		 List<String> legalEntities= new  List<String>{'EnelSole','EnelXItalia'};																		
        if(configurationItemAttrListId.isEmpty()) return;
        List<NE__OrderItem__c> orderItems= [SELECT Id FROM NE__OrderItem__c WHERE Id IN (SELECT NE__Order_Item__c FROM NE__Order_Item_Attribute__c WHERE Id IN :configurationItemAttrListId ) AND NE__OrderId__r.XC_Segment__c !='B2C' AND NE__OrderId__r.XC_LegalEntity__c IN :legalEntities AND XC_NE_Type__c='InOrder' AND NE__OrderId__r.NE__Type__c='InOrder' AND NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c ='eCity']; //INC000088755213-elisa.caldini@accenture.com-14.06.2022-add condition on business line eCity
		if(orderItems.isEmpty()) return;
        if(!orderItems.isEmpty()){
            System.enqueueJob(new QueueableAssignOwnerOppConfPreAppr(orderItems));
        }
    }

    public  class QueueableAssignOwnerOppConfPreAppr implements Queueable, Database.AllowsCallouts{

        private List<NE__OrderItem__c> listNew;

        public QueueableAssignOwnerOppConfPreAppr(List<NE__OrderItem__c> listNew){
            this.listNew =listNew;
        }

        public void execute(QueueableContext qc) {
            AssignOwnerConfigurationAndOpportunityPreApproval(listNew);
        }
    }												 
        
  
       
    /**
     * @description Method Util to assign Owner to configuration type Opty and Opportunity before approval process (use method in trigger of Configuration Item Attribute on AfterInsert)
     *
     * @param listNew the list new of NE__Order_Item_Attribute__c
     * 
     */
   

    public static void  AssignOwnerConfigurationAndOpportunityPreApproval( List<NE__OrderItem__c> confs){

       
		List<Id> configurationItemListId = XC_UTIL_Sobject.getListFieldValues(confs, 'Id');
        List<NE__Order__c> configurations =new List <NE__Order__c>();
        List<NE__Order__c> allConfigurations=[SELECT Id,RecordTypeId, XC_Segment__c,XC_LegalEntity__c,OwnerId,NE__AccountId__c,NE__OptyId__c,NE__Type__c FROM NE__Order__c WHERE Id IN (SELECT NE__OrderId__c FROM NE__OrderItem__c WHERE Id IN :configurationItemListId )];
        List<Opportunity> opportunities=new List<Opportunity>();
        configurations=retrieveConfigurations(allConfigurations,false);
        opportunities=retrieveOpportunites(configurations,'');
		assignConfAndOpp(opportunities,configurations,false);
    }

     /**
     * @description Method  to assign Owner to configuration type Opty and Opportunity after approval process (use method of trigger of Configuration onBeforeUpdate)
     *
     * @param mapOld the map of NE__Order__c before update
     *  @param mapNew the map of NE__Order__c after update
     */

    public static void  AssignOwnerConfigurationAndOpportunityAfterApproval( Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_RequestForApproval__c'}, mapOld, mapNew);
        List<NE__Order__c> configurations= new  List<NE__Order__c>();
        List<Opportunity> opportunities=new List<Opportunity>();
        configurations=retrieveConfigurations(listChanged,true);
        if(configurations.isEmpty()) return;
        opportunities=retrieveOpportunites(configurations,'In Progress');
        assignConfAndOpp(opportunities,configurations,true);
    }

    

    /**
     * @description retrieve configuration type opty , not equal B2C and legal entity is EnelxItalia or EnelSole before or after process approval
     *
     * @param confs list of NE__Order__c
     * @param appr identify pre or after process approval
     * @return List<NE__Order__c>
     */


    public static List<NE__Order__c> retrieveConfigurations(List<NE__Order__c> confs,Boolean appr){
        List<String> legalEntities= new  List<String>{'EnelSole','EnelXItalia'};
        List<NE__Order__c> configurationPres=new List<NE__Order__c>();
        List<NE__Order__c> configurationPost=new List<NE__Order__c>();
        Id orderRT = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        for(NE__Order__c ord:confs ){
            if(ord.RecordTypeId == orderRT && ord.NE__Type__c=='InOrder' && ord.XC_Segment__c !='B2C' && legalEntities.contains(ord.XC_LegalEntity__c)){
                configurationPres.add(ord);
                if(appr && ord.XC_RequestForApproval__c =='Approval Received'){
                    configurationPost.add(ord);
                }
            }   
        }
        if(appr){
            return configurationPost;
        }else{
            return configurationPres;
        }
    }

    /**
     * @description retrieve opportunity in case businessLine eCity  before or after process approval
     *
     * @param orders list of NE__Order__c
     * @param stageName stageName of Opportunity
     * @return List<Opportunity>
     */

    public static List<Opportunity> retrieveOpportunites(List<NE__Order__c> orders, String stageName){
        List<Opportunity> opportunities=new List<Opportunity>();
        List<String> oppIds=new List<String>(); 
        oppIds=XC_UTIL_Sobject.getListFieldValues(orders,'NE__OptyId__c');
        if(String.isBlank(stageName)){
            opportunities=[SELECT Id,OwnerId,AccountId FROM Opportunity  WHERE Id IN : oppIds AND XC_BusinessLine__c ='eCity'];
        } else{
            opportunities=[SELECT Id,OwnerId,AccountId FROM Opportunity  WHERE Id IN : oppIds AND StageName = :stageName AND XC_BusinessLine__c ='eCity'];
        }
        
        return opportunities;
    }

     /**
     * @description assign Owner to configuration to AccountTeamMeamber before and after process approval
     *
     * @param mapByOptydAndAccountId map is a key a NE__Order__c and value is AccountId of configuration
     * @param approval is before or after approval process
     * @return List<NE__Order__c>
     */

    public static List<NE__Order__c> assignOptyToAccountTeamMember(Map<NE__Order__c,Id> mapByOptydAndAccountId, boolean approval){
        
        List<Id> userKAMIds=new List<Id>();
        List<Id> userTIds=new List<Id>();
        List<Id> userTGIds=new List<Id>();
        List<NE__Order__c> confToUpdates= new List<NE__Order__c>();
        System.debug('mapByOptydAndAccountId' +mapByOptydAndAccountId);
        List<String> roles=new  List<String>{'KAM','Tecnico','Tecnico Gestionale'};
        List<AccountTeamMember> accountTeamMembers=[SELECT UserId,AccountId,TeamMemberRole FROM AccountTeamMember WHERE AccountId IN : mapByOptydAndAccountId.values() AND TeamMemberRole IN : roles ];
        System.debug('accountTeamMembers' + accountTeamMembers);
        for(NE__Order__c ord  :mapByOptydAndAccountId.keySet() ){
            for(AccountTeamMember memb :accountTeamMembers){
                if(mapByOptydAndAccountId.get(ord) == memb.AccountId  ){
                    if(memb.TeamMemberRole== 'KAM'){
                        userKAMIds.add(memb.UserId);
                    }else if(memb.TeamMemberRole== 'Tecnico Gestionale'){
                        userTGIds.add(memb.UserId);
                    }else if(memb.TeamMemberRole== 'Tecnico'){
                        userTIds.add(memb.UserId);
                    }
                }
            }
            System.debug('userTIds' +userTIds);
            if( approval && (userKAMIds.size()==1 || userTGIds.size()==1) ){
                if(((ord.XC_CapexFullLife__c + ord.XC_CostFull_Life__c)<= 7000) &&  !userTGIds.isEmpty()  ){
                    ord.OwnerId=userTGIds[0];
                    confToUpdates.add(ord);
                }else if((ord.XC_CapexFullLife__c + ord.XC_CostFull_Life__c)> 7000 &&  !userKAMIds.isEmpty() ){
                    ord.OwnerId=userKAMIds[0];
                    confToUpdates.add(ord);
                }
            }else if( !approval && userTIds.size()==1 ){
                    ord.OwnerId=userTIds[0];
                    confToUpdates.add(ord);
            }
        }
        if( !approval){
            XC_UTIL_Sobject.updateListRecords(confToUpdates);

        }
       
        return confToUpdates;
    }

    /**
     * @description assign Owner to Opportunity and Configuration before and after process approval
     *
     * @param opportunities list of Opportunity
     * @param configurations list of NE__Order__c
     * @param isApprove before or after process approval
     */

    public static void assignConfAndOpp( List<Opportunity> opportunities, List<NE__Order__c> configurations, Boolean isApprove){
        Boolean addConf= false;
        Map<NE__Order__c,Id> confAndAccountIdMap=new Map <NE__Order__c,Id>();
        List<Opportunity> oppafterQuery=new List<Opportunity>();
        List<NE__Order__c> configurationsChangeOwner=new  List<NE__Order__c>();
        List<Opportunity> opportunitytoUpdate =new List<Opportunity>();
        for(Opportunity opp :opportunities){
            for(NE__Order__c conf: configurations){
                if(conf.NE__OptyId__c == opp.Id){
                    confAndAccountIdMap.put(conf,conf.NE__AccountId__c);
                    addConf=true;
                }
            }
            if(addConf){
                oppafterQuery.add(opp);
            }
        }
        
        if(!confAndAccountIdMap.isEmpty()){
             configurationsChangeOwner= assignOptyToAccountTeamMember(confAndAccountIdMap,isApprove);
        }
        System.debug('configurationsChangeOwner' +configurationsChangeOwner);
        for(NE__Order__c c :configurationsChangeOwner){
            for(Opportunity o : oppafterQuery){
                if(o.Id == c.NE__OptyId__c && o.OwnerId != c.OwnerId){
                    o.OwnerId=c.OwnerId;
                    opportunitytoUpdate.add(o);
                    
                }   
            }
        }
        if(!opportunitytoUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(opportunitytoUpdate);
        }
    }
 
    public static void assignOwnerIfQuoteApproved(List<NE__Order__c> listNew){
        Map<Id, List<NE__Order__c>> opportunityOrdersMap = new Map<Id, List<NE__Order__c>>();
        Id orderRecTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        for(NE__Order__c ord : listNew){
            if(ord.XC_Segment__c == 'B2C' && ord.RecordTypeId == orderRecTypeId && ord.NE__Type__c == 'InOrder' && ord.XC_QuotePresent__c){
                    if(!opportunityOrdersMap.containsKey(ord.NE__OptyId__c)){
                        opportunityOrdersMap.put(ord.NE__OptyId__c, new List<NE__Order__c>());
                    }
                    opportunityOrdersMap.get(ord.NE__OptyId__c).add(ord);
            }
        }

        if(!opportunityOrdersMap.isEmpty()){
            List<NE__Order__c> quotes = new List<NE__Order__c>([SELECT Id, OwnerId, NE__OptyId__c
                                                                FROM NE__Order__c 
                                                                WHERE RecordType.DeveloperName =: Label.XC_CL_Configuration_RtQuote 
                                                                AND NE__OptyId__c in: opportunityOrdersMap.keySet() 
                                                                AND XC_Status__c =: Label.XC_CL_Configuration_QuoteAccepted]);
            
            //It's not necessary to update listNew directly because the pointers in opportunityOrdersMap.values() point to a sub set of listNew
            for(NE__Order__c quote : quotes){
                for(NE__Order__c ord : opportunityOrdersMap.get(quote.NE__OptyId__c)){
                    ord.OwnerId = quote.OwnerId;
                }
            }
        }
    }

}