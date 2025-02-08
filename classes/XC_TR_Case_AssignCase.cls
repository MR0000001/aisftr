public class XC_TR_Case_AssignCase {
    
    public static void caseAssignment(List<Case> caseList){
		List <Case> caseToBeAssigned = new List <Case> ();
		for (case c : caseList ){
			if(c.XC_Segment__c != 'B2C'){
				caseToBeAssigned.add(c);
			}
		}
        if(caseToBeAssigned.isEmpty()) return;
        Map<Id,User> user = new Map<Id,User>([Select id, Profile.UserLicense.Name from user where id IN:XC_UTIL_Sobject.getSetIdsOnField(caseToBeAssigned, 'OwnerId') ]);
        Set<Id> idCase =new Set<Id>();
        List<Case> caseToUpdate = new List<Case>();
        Map<Id,Id> mapcaseidAccount =new Map<Id,Id>(); // [gaurav.tejpal@accenture.com, 06/01/2022,FUNZIONALITÀ TASTO RECLAMO , NR2255,ENEL X-r12]
        for(Case c:caseToBeAssigned){
            if(user.get(c.OwnerId) != null && user.get(c.OwnerId).Profile != null && user.get(c.OwnerId).Profile.UserLicense != null){
                System.debug('@@@ GS -->' + user.get(c.OwnerId).Profile.UserLicense.Name);
                // [ BEGIN, gaurav.tejpal@accenture.com, 06/01/2022,FUNZIONALITÀ TASTO RECLAMO , NR2255,ENEL X-r12]  
                if (c.Origin == Constants.ORIGIN && /*c.XC_Segment__c == Constants.XC_SEGMENT*/ c.XC_BusinessLine__c == 'eCity' && c.Reason == Constants.REASON && c.XC_Subtype__c == Constants.XC_SUBTYPE && c.SubCause__c == Constants.SUBCAUSE) { //[DeAv 15.02.2022 removed check on Segment and added check on businessline]
                    System.debug('@@@  Else  CaseId-AccountId -->' + c.id + '-'+c.AccountId);
                    mapcaseidAccount.put(c.id,c.AccountId);
                    futureCustomAssignment(mapcaseidAccount);
                }
                else if(user.get(c.OwnerId).Profile.UserLicense.Name =='Partner Community'){
                    System.debug('@@@ GS 1 -->' + user.get(c.OwnerId).Profile.UserLicense.Name);
                    idCase.add(c.id);
                    caseToUpdate.add(c);   
                    futureMethod(idCase);
                }
                // [ END, gaurav.tejpal@accenture.com, 06/01/2022,FUNZIONALITÀ TASTO RECLAMO , NR2255,ENEL X-r12]  
            }
        }
    }

    @future
    public static void futureMethod (Set<Id> idCase ){
        List<Case> caseList = [Select id from Case where id IN :idCase];
        System.debug('@@@ GS 2 -->');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        Database.update(caseList, dmo);
    }

    /** ​
     * @author  - Gaurav Tejpal
     * @date      - 6th Jan 2022,NR2255 – FUNZIONALITÀ TASTO RECLAMO,ENEL X-r12
     * @Description – Reassign Case record after creation .​
     * @param  - Map <Id,Id>(key caseId, value accountId)
     */
    @future
    public static void futureCustomAssignment(Map<Id,Id> mapcaseidAccount ){
        System.debug('@@@  futurecustomassginment  -->');
        List<Case> caseList=new List<Case>();
        List<AccountTeamMember> accTMList =[Select Id,AccountId,UserId,TeamMemberRole 
        from AccountTeamMember where TeamMemberRole='Tecnico Gestionale' 
        and AccountId IN :(mapcaseidAccount.values())];
        if(accTMList.isEmpty()) return;
        Map<Id,Id> accIdUserId=new Map<Id,Id>();
        for(AccountTeamMember a : accTMList)
        {
            accIdUserId.put(a.AccountId,a.UserId);
        }
        //Database.update(caseList);

		List<CustomNotificationType> typeNotify = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'FieldUpdateNotification'];
		for(Id cid: mapcaseidAccount.KeySet())
		{
			Id accountid=mapcaseidAccount.get(cid);
			Case cnew = new Case(id=cid, OwnerId=accIdUserId.get(accountid));
			caseList.add(cnew);
			System.debug('@@@  Case updation caseid-OwnerId  -->' + cnew.id + '-'+cnew.OwnerId); 
			//SET USER TO BE NOTIFIED 
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setBody('Aperto Case di Reclamo su guasto fuori SLA.');
			notification.setTitle('Nuova Notifica');
			notification.setSenderId(Userinfo.getUserId());
			notification.setNotificationTypeId(typeNotify?.get(0).Id );
			notification.setTargetId(cid);    // target case id 
			notification.send(new Set<String>{accIdUserId.get(accountid)});  // target user id.
		}
        Database.update(caseList);
    }
}