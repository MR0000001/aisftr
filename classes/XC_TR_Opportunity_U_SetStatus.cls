/**
 * The Class XC_TR_Opportunity_U_SetStatus.
 *
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 27/09/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Opportunity_U_SetStatus – Set the Opportunity Status from Configuration
 */ 

public class XC_TR_Opportunity_U_SetStatus {

	/** 
	 *@description Sets the status from configuration.
	 *
	 * @param listNew the list new
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void setStatusFromConfiguration(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){

		List<Opportunity> listOppChanged = new List<Opportunity>();
		//START-CR725-elisa.caldini@accenture.com-17.03.2022
        Boolean isPreviewCart =false; 
        //END-CR72-5elisa.caldini@accenture.com-17.03.2022													
        for(Opportunity opp : listNew){
             System.debug('@@@mapOld-->'+mapOld.get(opp.Id).get('XC_NumberOfConfiguration__c'));
        	System.debug('@@@mapNew-->'+mapNew.get(opp.Id).get('XC_NumberOfConfiguration__c'));
            System.debug('@@@opp.XC_NumberOfConfiguration__c-->'+opp.XC_NumberOfConfiguration__c);           
            if(mapNew.get(opp.Id).get('XC_NumberOfConfiguration__c')!=mapOld.get(opp.Id).get('XC_NumberOfConfiguration__c') && 
               mapOld.get(opp.Id).get('StageName') == Label.XC_CL_Opportunity_Draft && opp.XC_Segment__c   == 'B2C'){
                listOppChanged.add(opp);
            }else if(mapNew.get(opp.Id).get('XC_NumberOfConfiguration__c')!=mapOld.get(opp.Id).get('XC_NumberOfConfiguration__c') && 
            mapOld.get(opp.Id).get('StageName') == 'Qualified Potential Opportunity' && opp.XC_OpportunityType__c != 'Business Plan'){
                listOppChanged.add(opp);
            }else if(opp.XC_NumberOfConfiguration__c ==1 && opp.XC_Segment__c != 'B2C' && opp.StageName=='Draft'){ //START-CR725-elisa.caldini@accenture.com-17.03.2022
                listOppChanged.add(opp);
                isPreviewCart=true;
            }//END-CR725-elisa.caldini@accenture.com-17.03.2022
        }
        
        for(Opportunity oppChanged : listOppChanged){
        	System.debug('@@@Number of Configuration-->'+oppChanged.XC_NumberOfConfiguration__c);
	        if (oppChanged.XC_NumberOfConfiguration__c > 0 && !isPreviewCart){ //CR725-elisa.caldini@accenture.com-17.03.2022
	        	oppChanged.StageName = Label.XC_CL_Opportunity_InProgress; 
            } else if(oppChanged.XC_NumberOfConfiguration__c > 0 &&  oppChanged.StageName=='Draft' && isPreviewCart){//START-CR725-elisa.caldini@accenture.com-17.03.2022
                oppChanged.StageName ='Qualified Potential Opportunity'; 
            }//END-CR725-elisa.caldini@accenture.com-17.03.2022
        }   
        
    }

    /**
     * @description Sets the closing user.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void setClosingUser(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew) {

        List<Opportunity> listOppChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'StageName'}, mapOld, mapNew);

        for(Opportunity oppChanged : listOppChanged){
            if((oppChanged.StageName == Label.XC_CL_Opportunity_ClosedWon) || (oppChanged.StageName == Label.XC_CL_Opportunity_ClosedLost)) {
                mapNew.get(oppChanged.Id).XC_ClosingUser__c = UserInfo.getUserId();
                mapNew.get(oppChanged.Id).XC_ClosureDateTime__c = System.now();
            }
        }   

    }
    /**
     * @description When the invited field is set as true, the stage is set as InProgress
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void setStageInProgress(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew) {

        List<Opportunity> listOppChanged = new List<Opportunity>();
        for(Opportunity opp : listNew){
            if(opp.XC_Segment__c != 'B2C'){
                listOppChanged.add(opp);
            }
        }

        List<String> stageCloseList = new List<String>{'Closed Won', 'Closed Lost','Abandoned'}; //DeAv 19.03.2022 CR758 
        
        for(Opportunity oppChanged : listOppChanged){
            if(oppChanged.XC_Invited_Checkbox__c && ! mapOld.get(oppChanged.Id).XC_Invited_Checkbox__c ) {
                oppChanged.StageName = Constants.OPP_STAGE_INPROGRESS;
                oppChanged.XC_SubStatus_GB__c = null;
            }
            if(oppChanged.StageName == 'Qualified Potential Opportunity' &&  mapOld.get(oppChanged.Id).StageName != 'Qualified Potential Opportunity'){
                oppChanged.XC_PipelineStatus__c = 'Qualified potential opportunity';
                oppChanged.XC_QualifiedPotentialOpportunityDate__c = System.today();
            }
            //DeAv 19.03.2022 CR758 START
            if(oppChanged.StageName == 'In Progress' &&  mapOld.get(oppChanged.Id).StageName != 'In Progress'){
                oppChanged.XC_InProgressOpportunityDate__c = System.today();
            }
            if(oppChanged.StageName == 'Prepared Proposal' &&  mapOld.get(oppChanged.Id).StageName != 'Prepared Proposal'){
                oppChanged.XC_PreparedProposalDate__c = System.today();
            }
            if(oppChanged.StageName == 'Presented Proposal' &&  mapOld.get(oppChanged.Id).StageName != 'Presented Proposal'){
                oppChanged.XC_PresentedProposalDate__c = System.today();
            }
            if(oppChanged.StageName == 'Accepted Proposal' &&  mapOld.get(oppChanged.Id).StageName != 'Accepted Proposal'){
                oppChanged.XC_AcceptedProposalDate__c = System.today();
            }
            if(oppChanged.StageName == 'Signed Contract' &&  mapOld.get(oppChanged.Id).StageName != 'Signed Contract'){
                oppChanged.XC_SignedContractDate__c = System.today();
            }
            if(stageCloseList.contains(oppChanged.StageName) && !stageCloseList.contains(mapOld.get(oppChanged.Id).StageName)){
                oppChanged.CloseDate = System.today();
            }
            //DeAv 19.03.2022 CR758 END
        }   

    }
    public static void createNotification(List<Opportunity> listNew, Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        List<String> opportunityId = new List<String>();
        List<XC_Customer_Interaction__c> surveyList = new List<XC_Customer_Interaction__c>();
        for(Opportunity opp : listNew){
            if((opp.XC_Segment__c == 'B2G')&& 
                (((opp.StageName == 'Abandoned') && (mapOld.get(opp.id).StageName != 'Abandoned')) || ((opp.StageName == 'Closed Lost') && (mapOld.get(opp.id).StageName != 'Closed Lost')) && opp.XC_BusinessLine__c == 'eCity')
            ){
                opportunityId.add(opp.id);
            }
        }
        if(opportunityId.isEmpty()){
            return;
        }
        List<Opportunity> oppInfo = [SELECT id, AccountId, XC_Contact__c, XC_Contact__r.Name, XC_Contact__r.Email, XC_Contact__r.XC_Preferredlanguageofcontact__c, XC_LegalEntity__c, XC_Segment__c FROM Opportunity WHERE id IN: opportunityId];
        List<NE__OrderItem__c> confItemList = [Select id, NE__ProdId__c, NE__OrderId__r.NE__OptyId__c from NE__OrderItem__c where NE__OrderId__r.NE__OptyId__c IN: opportunityId AND NE__Parent_Order_Item__c = null];
        for(Opportunity opp : oppInfo){
            XC_Customer_Interaction__c survey = new XC_Customer_Interaction__c();
            survey.XC_OpportunityId__c = opp.id;
            survey.XC_ContactId__c = opp.XC_Contact__c;
            survey.XC_AccountId__c = opp.AccountId;
            survey.XC_Recipient__c = opp.XC_Contact__r.Name;
            survey.XC_Email__c = opp.XC_Contact__r.Email;
            survey.XC_Preferredlanguageofcontact__c = opp.XC_Contact__r.XC_Preferredlanguageofcontact__c;
            survey.XC_Channel__c = 'Email';
            survey.XC_Communication_Type__c = 'Survey_Offer_Not_Accepted';
            survey.XC_LegalEntity__c = opp.XC_LegalEntity__c;
            survey.XC_Segment__c = opp.XC_Segment__c;
            survey.XC_SurveyId__c = 'Survey_Offer_Not_Accepted';
            if(confItemList != null && !confItemList.isEmpty()){
                for(NE__OrderItem__c oi : confItemList){
                    if(oi.NE__OrderId__r.NE__OptyId__c == opp.id){
                        survey.XC_ProductId__c = oi.NE__ProdId__c;
                    }
                }
            }
            surveyList.add(survey);
        }
        XC_UTIL_DML.insertRecords(surveyList);

    }
}