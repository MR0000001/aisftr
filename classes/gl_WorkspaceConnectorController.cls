/**
 * @File Name          : gl_WorkspaceConnectorController.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 2/7/2020, 15:58:53
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
global class gl_WorkspaceConnectorController {

	public static Boolean personAccountsEnabled = Schema.sObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
	
	@RemoteAction
	global static String IsPersonAccountEnabled()
	{
        system.debug('in   IsPersonAccountEnabled' );
		if (personAccountsEnabled == true)
			return 'true';
		return 'false';	
	}
	
	
   	@RemoteAction
   	global static String findContactFromcase(String caseId)
    {
        system.debug('findContactFromcase using  ' + caseId);
        if (caseId == null || caseId == ''){
        	return null;
		}
        String query;
        List<Case> cases = null;
        List<List<SObject>> cobjects = null;
        try {
        	//List<Case> cases = [SELECT ContactId FROM Case WHERE Id= :caseId];   
        	query = 'FIND \'' + caseId + '\' IN ALL FIELDS RETURNING Case(ContactId WHERE Id = \'' + caseId + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
	        	cases = ((List<Case>)cobjects[0]);
         		if(cases != null && !cases.isEmpty()) {
	               // return the first case found (should only be one)                            
	               for (Case c : cases) {
	                   return c.ContactId;
	               } 
	           	}
        	}
        } catch(QueryException e){
            return null; 
        }
        return null; 
    }
  

    @RemoteAction
    global static Object findObjectFromANI(String ANI)
    {
        system.debug('*** findObjectFromANIfor '+ANI);
        
        Integer listSize = 0; 
        //List<SObject> objList;
        SObject obj_found = null;     
        try{
            
            List<List<SObject>> aobjects = [FIND :ANI IN PHONE FIELDS RETURNING Account];
            if (!aobjects.isEmpty()){
              List<Account> accounts = ((List<Account>)aobjects[0]);
              listSize = accounts.size();
              system.debug('*** accounts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize != 0){
                  for (List<SObject> objList : aobjects)
                      for (SObject aobj : objList){
                        obj_found = aobj;
                        system.debug('*** findObjectFromANI account = '+ obj_found.Id);
                  } 
              }
            } 
            
            List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
            if (!cobjects.isEmpty()){
              List<Contact> contacts= ((List<Contact>)cobjects[0]);
              listSize = contacts.size();
              system.debug('*** contacts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 1 && obj_found != null){
                    return 'multiple found';
              }
              if(listSize != 0){
                  for (List<SObject> objList : cobjects)
                      for (SObject cobj : objList){
                        obj_found = cobj;
                        system.debug('*** findObjectFromANI contact = '+ obj_found.Id);
                      } 
                  }
            }                      

            List<List<SObject>> lobjects = [FIND :ANI IN PHONE FIELDS RETURNING Lead];
            if (!lobjects.isEmpty()){
              List<Lead> leads= ((List<Lead>)lobjects[0]);
              listSize = leads.size();
              system.debug('*** leads listSize = ' + listSize);              
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 1 && obj_found != null){
                    return 'multiple found';
              }
              if(listSize != 0){                            
                  for (List<SObject> objList : lobjects)
                      for (SObject lobj: objList){
                        obj_found = lobj;
                        system.debug('*** findObjectFromANI lead= '+obj_found.Id);
                      } 
              }
            }
            
            if(obj_found != null)              
                return obj_found; 
            return 'not found';

        }
        catch(QueryException e){
            return 'not found'; 
        }        
    }    
    
    @RemoteAction
    global static Object findObjectFromANIByType(String ANI, String searchObjectType)
    {
        system.debug('*** findObjectFromANIByType for ANI - '+ ANI + ', searchObjectType - ' + searchObjectType);
        Integer listSize = 0;      
        String query;   
        try{        	
        	List<List<SObject>> aobjects = null;        	
            if (personAccountsEnabled == false){
	        	query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name,Phone)';  
            }/*
            else{
            	if (searchObjectType == 'personaccount'){
            		query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail where IsPersonAccount = true)'; 
            	}
            	else{
            		query='FIND :ANI IN PHONE FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail)'; 
            	}            	
            }*/
            aobjects = search.query(query);
            
            if (aobjects != null && !aobjects.isEmpty()){
            	List<Account> accounts = ((List<Account>)aobjects[0]);
              	listSize = accounts.size();
              	system.debug('*** findObjectFromANIByType accounts listSize = ' + listSize);
              	if(listSize != 0){              	
                    return accounts;
              	}
            }            
            return 'not found';
        }
        catch(Exception e){
            return 'not found'; 
        }             
    }    
    
    
    @RemoteAction
    global static Object findContactFromANI(String ANI)
    {
    	system.debug('*** findContactFromANI '+ANI);    
        if (ANI == null || ANI=='')
    		return null;   
        try{                                  
            List<List<SObject>> cobjects = [FIND :ANI IN PHONE FIELDS RETURNING Contact];
            Integer listSize = cobjects.size();
            system.debug('*** listSize = ' + listSize);
            if(listSize > 1){
                    return 'multiple found'; //not expected
            }
            if (!cobjects.isEmpty()){
              List<Contact> contacts = ((List<Contact>)cobjects[0]);
              listSize = contacts.size();
              system.debug('*** contacts listSize = ' + listSize);
              if(listSize > 1){
                    return 'multiple found';
              }
              if(listSize == 0){
                  return 'not found';
              }
              for (List<SObject> objList : cobjects)
                  for (SObject cobj : objList){
                    system.debug('*** findContactFromANI contact = '+ cobj.Id);
                    return cobj;
                  } 
            }
        }
        catch(Exception e){
            return null; 
        } 
        return null;        
    }

    @RemoteAction
    global static Object findContactFromEmailAddress(String address)
    {
		system.debug('*** findObjectFromEmailAddress' + address);   
		if (address == null || address=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;   
		try {
		    //List<Contact> objects = [select name from contact where email= :address ];
		    query='FIND \'' + address + '\' IN ALL FIELDS RETURNING Contact(Name WHERE email = \'' + address + '\')';
        	cobjects = search.query(query);
		    if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromEmailAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
		}
		catch(QueryException e){
		    return null; 
		}  
		return null;       
    }
    
    @RemoteAction
    global static Object findContactFromChatAddress(String theName)
    {
        system.debug('*** findObjectFromChatAddress' + theName); 
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;  
        try {
            //List<Contact> objects = [select name from contact where name= :theName];
            query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromChatAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
        }
        catch(QueryException e){
            return null; 
        } 
        return null; 
    }

        
    @RemoteAction
    global static Object findContactFromWorkItemAddress(String theName)
    {
        system.debug('*** findContactFromWorkItemAddress' + theName);  
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;       
        try {
        	query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromWorkItemAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}
        }
        catch(QueryException e){
            return null; 
        }
        return null;         
    }  

    @RemoteAction
    global static Object findContactFromOpenMediaAddress(String theName)
    {
        system.debug('*** findContactFromOpenMediaAddress' + theName); 
        if (theName == null || theName=='')
    		return null; 
    	String query;   
    	List<Contact> contacts = null;
    	List<List<SObject>> cobjects = null;        
        try {
        	query='FIND \'' + theName + '\' IN ALL FIELDS RETURNING Contact(Name WHERE name = \'' + theName + '\')';
        	cobjects = search.query(query);
        	if (cobjects != null && !cobjects.isEmpty())
        	{
        		contacts = ((List<Contact>)cobjects[0]);			    
			    if(contacts != null && !contacts.isEmpty()) {
			    	Integer listSize = contacts.size();
			    	if (listSize == 1){
						for (Contact obj : contacts) {
						    system.debug('*** findContactFromOpenMediaAddress contact = '+ obj.Name);
						    return obj;
						}
			    	}
			    }      
        	}            
            return null; 
        }
        catch(QueryException e){
            return null; 
        } 
        return null;        
    }
 
 
    @RemoteAction
    global static Object findAccountFromOpenMediaAddress(String theName, String searchObjectType)
    {
        system.debug('*** findAccountFromOpenMediaAddress' + theName + ', searchObjectType - ' + searchObjectType);
        return findObjectByType('Name', theName, searchObjectType);
    }

	/***********************************************CUSTOM CODE FOR ENEL X XCUSTOMER****************************************/

	/**
	*@Author: Francesco Imperioli
	*@Description: Manage XC_CTI_Interaction creation/updates on inbound Calls/inbound Call transfers
	*History: Last Updated 23-07-2019
	* */
    @RemoteAction 
    global static String createInteraction(Map<String,String> activityMap){
         String res;
         system.debug('******************* createInteraction ' + JSON.Serialize(activityMap) );


         XC_CTI_Interaction__c ci = new XC_CTI_Interaction__c();
         ci.XC_Phone__c = activityMap.get('Phone');
         ci.XC_Connection_ID__c = activityMap.get('GenesysId');
		 ci.XC_Source__c = activityMap.get('destination');

         ci.XC_InteractionStatus__c = 'Open';
		 ci.XC_Communication_Type__c = 'Inbound Call';
		 
		 //check additionalInformations from Italian CTI Phone Bar
		 String genesysQueue = activityMap.containsKey('callQueue') ? String.valueOf(activityMap.get('callQueue')) : '';
		 String IVRDirectionFullString = activityMap.containsKey('IVRDirection') ? String.valueOf(activityMap.get('IVRDirection')) : '';
		 String partnerName = activityMap.containsKey('partner') ? String.valueOf(activityMap.get('partner')) : '';
		 String serviceName = activityMap.containsKey('serviceName') ? String.valueOf(activityMap.get('serviceName')) : '';

		 ci.XC_ServiceName__c = serviceName;
		 ci.XC_ReceivingPartner__c = partnerName;

		 if(String.isNotBlank(IVRDirectionFullString) && IVRDirectionFullString.split('_').size()>=3){
			ci.XC_IVRBranch__c = IVRDirectionFullString.split('_')[1];
			ci.XC_FreeNumber__c = IVRDirectionFullString.split('_')[2];
		 }


		 //F.I. 09/07/2019 SEARCH QUERY IN ORDER TO MATCH LEAD/ACCOUNTS
		 if(!String.isBlank(activityMap.get('Phone'))){

			 //SOSL TO SEARCH INSIDE PHONES
			 List<List<Sobject>> searchContactsByPhone = [FIND :activityMap.get('Phone') IN PHONE FIELDS RETURNING  Contact(Id,XC_ContactPhone__c,XC_PhonePrefix__c,AccountId),Lead(Id,XC_LeadPhone__c,XC_PhonePrefix__c)];
			 
			 List<Contact> contactsFound = (List<Contact>) searchContactsByPhone[0];
			 List<Lead> leadsFound = (List<Lead>) searchContactsByPhone[1];
			 Boolean recordAssigned = false;
			 Integer numOfMatches=contactsFound.size()+leadsFound.size();

			 if(leadsFound.isEmpty() && !contactsFound.isEmpty() && contactsFound.size()==1){
				 ci.XC_ContactId__c=contactsFound[0].Id;
				 ci.XC_Phone__c = contactsFound[0].XC_ContactPhone__c;
				 ci.XC_Customer_Phone_Prefix__c = contactsFound[0].XC_PhonePrefix__c;
				 ci.XC_AccountId__c = contactsFound[0].AccountId;
				 recordAssigned=true;
			 }else if(contactsFound.isEmpty() && !leadsFound.isEmpty() && leadsFound.size()==1){
				 ci.XC_LeadId__c=leadsFound[0].Id;
				 ci.XC_Phone__c = leadsFound[0].XC_LeadPhone__c;
				 ci.XC_Customer_Phone_Prefix__c = leadsFound[0].XC_PhonePrefix__c;
				 recordAssigned=true;
			 }

			//if we have multiple matches we update a flag in order to show components on page
			if(numOfMatches>1){
				ci.XC_HasMultipleMatch__c=true;
			}

		 }	
         try{
          
          insert ci;
          system.debug('******************* entrato in insert Interaction' );
		  res = ci.Id;

        }catch(Exception e) {
            system.debug('******************* errore in insert Interaction' +e); 
            res = e.getMessage();
        }
         return res;
    }


	@RemoteAction
    global static String updateInteraction(Map<String,String> objectMap){

		String durationInSecs = objectMap.get('Call Duration');
		String dialStatus = objectMap.get('dialStatus');
		String connectionId = objectMap.get('GenesysId');

        String res;
        String currentUser = UserInfo.getUserId();
        System.debug('entro in updateInteraction con userId = '+currentUser);
        List<XC_CTI_Interaction__c> ciList = [SELECT id, CreatedById, XC_InteractionStatus__c,XC_Connection_ID__c,XC_Communication_Type__c,XC_Source__c,XC_Call_EndDate__c FROM XC_CTI_Interaction__c 
        WHERE XC_InteractionStatus__c ='Open' AND CreatedById=:currentUser ORDER BY CreatedDate DESC LIMIT 1];
        
		
		if(!ciList.isEmpty()){
            
			ciList[0].XC_InteractionStatus__c='Close';
			ciList[0].XC_Call_EndDate__c = DateTime.now();

            if(durationInSecs!=null){
            ciList[0].XC_Call_Duration__c = String.valueOf(durationInSecs);
            }

			/**setup fields for outbound call closure**/

			if(String.isNotBlank(connectionId) && String.isBlank(ciList[0].XC_Connection_ID__c)){
				ciList[0].XC_Connection_ID__c = connectionId;
			}

			if(ciList[0].XC_Communication_Type__c.equalsIgnoreCase('Outbound Call') && String.isBlank(ciList[0].XC_Source__c)){
				ciList[0].XC_Source__c = objectMap.get('Phone');
			}



            try{
                update ciList[0];
                res = ciList[0].id;
             }catch(Exception e) {
                system.debug(e.getMessage()); 
                res = e.getMessage();
            }
        } return res;

    }


	@RemoteAction 
	global static String createInteractionOutBound(Map<String,String> objectMap){

		System.Debug('IN CREATE INTERACTION OUTBOUND');

		String result = '';
		String calledPhone = objectMap.get('number');
		String recordId = objectMap.get('recordId');
		String objectType = objectMap.containsKey('objectType') ? objectMap.get('objectType') : XC_UTIL_Sobject.getObjectType(recordId);
		String cId = objectMap.get('ConnectionId');

		//CREO UNA NUOVA CTI INTERACTION 
		try{


			List<XC_CTI_Interaction__c> originInteraction = new List<XC_CTI_Interaction__c>();

			XC_CTI_Interaction__c ci = new XC_CTI_Interaction__c();
			ci.XC_Phone__c = calledPhone;
			ci.XC_InteractionStatus__c = 'Open';
			ci.XC_Communication_Type__c = 'Outbound Call';
			ci.XC_Connection_ID__c = cId;

			//CASO PARTENZA DA CTI INTERACTION --> ASSOCIO I LEAD SE CI SONO
			if(objectType.equalsIgnoreCase('XC_CTI_Interaction__c')){
				originInteraction = [SELECT Id,XC_LeadId__c,XC_ContactId__c,XC_Customer_Phone_Prefix__c FROM XC_CTI_Interaction__c WHERE ID =:recordId LIMIT 1];
			}

			if(objectType.equalsIgnoreCase('XC_CTI_Interaction__c') && !originInteraction.isEmpty() && originInteraction[0].XC_LeadId__c!=null){

				ci.XC_LeadId__c = originInteraction[0].XC_LeadId__c;
				ci.XC_Customer_Phone_Prefix__c = originInteraction[0].XC_Customer_Phone_Prefix__c;

			}else if( objectType.equalsIgnoreCase('XC_CTI_Interaction__c') && !originInteraction.isEmpty() && originInteraction[0].XC_ContactId__c!=null){

				ci.XC_ContactId__c = originInteraction[0].XC_ContactId__c;
				ci.XC_Customer_Phone_Prefix__c = originInteraction[0].XC_Customer_Phone_Prefix__c;

			}else if(objectType.equalsIgnoreCase('Lead')){
				
				List<Lead> calledLead = [SELECT XC_PhonePrefix__c FROM Lead WHERE Id=:recordId LIMIT 1];
				ci.XC_LeadId__c = recordId;
				ci.XC_Customer_Phone_Prefix__c = calledLead[0].XC_PhonePrefix__c;


			}else if(objectType.equalsIgnoreCase('Contact')){

				List<Contact> calledContact = [SELECT XC_PhonePrefix__c FROM Contact WHERE Id=:recordId LIMIT 1];
				ci.XC_ContactId__c = recordId;
				ci.XC_Customer_Phone_Prefix__c = calledContact[0].XC_PhonePrefix__c;

			}else if(objectType.equalsIgnoreCase('Case')){

				ci.XC_CaseId__c = recordId;
				
			}else if(objectType.equalsIgnoreCase('Account')){

				List<Contact> calledContact = [SELECT Id,XC_PhonePrefix__c FROM Contact WHERE XC_PrimaryContact__c = true AND AccountId = :recordId LIMIT 1];
				ci.XC_ContactId__c = calledContact[0].Id;
				ci.XC_Customer_Phone_Prefix__c = calledContact[0].XC_PhonePrefix__c;

			}else{

				List<List<Sobject>> searchContactsByPhone = [FIND :calledPhone IN PHONE FIELDS RETURNING  Contact(Id),Lead(Id)];
				
				List<Contact> contactsFound = (List<Contact>) searchContactsByPhone[0];
				List<Lead> leadsFound = (List<Lead>) searchContactsByPhone[1];
				Boolean recordAssigned = false;


				if(leadsFound.isEmpty() && !contactsFound.isEmpty() && contactsFound.size()==1){
					ci.XC_ContactId__c=contactsFound[0].Id;
					recordAssigned=true;
				}else if(contactsFound.isEmpty() && !leadsFound.isEmpty() && leadsFound.size()==1){
					ci.XC_LeadId__c=leadsFound[0].Id;
					recordAssigned=true;
				}

				//if we have multiple matches we update a flag in order to show components on page
				if((!contactsFound.isEmpty() && !leadsFound.isEmpty())){
					ci.XC_HasMultipleMatch__c=true;
				}

			}

			insert ci;
			result = ci.Id;

		}catch(Exception e){
			System.Debug('EXCEPTION ON CREATEINTERACTIONOUTBOUND ' + e.getStackTraceString());
		}

		return result;

	}


	/***********************************************END CUSTOM CODE FOR ENEL X XCUSTOMER****************************************/

 
 	@RemoteAction 
 	global static String createActivity(Map<String,String> activityMap, String searchObjectType){
       


        String result = 'not found';
                        
        String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
        String taskPrefix = Schema.SObjectType.Task.getKeyPrefix(); 
        
        system.debug('*** createActivity accountPrefix = ' + accountPrefix);
        system.debug('*** createActivity contactPrefix = ' + contactPrefix);
        system.debug('*** createActivity leadPrefix = ' + leadPrefix);
        system.debug('*** createActivity casePrefix = ' + casePrefix);
        system.debug('*** createActivity taskPrefix = ' + taskPrefix);
        system.debug('*** createActivity duration = ' + activityMap.get('Call Duration'));


        String callType = activityMap.get('IXN Type');
        String mediaType = activityMap.get('Media Type');
        String d = activityMap.get('DATE');
        system.debug('*** d   '+ d);
        if(d == '0001-01-01 00:00:00')
        	d = '';
        String subject = callType + ' ' + mediaType + ' ' + d; 
        String objectToUse = '';

		//GETTING FIELDS FOR XCUSTOMER DEVELOPMENT

		result = updateInteraction(activityMap);
                
        // DateTime startDate=null;
        // try{
        // 	startDate = (activityMap.get('StartDate')=='' && activityMap.get('StartDate')==null) ? null : dateTime.valueOf(activityMap.get('StartDate'));
        // }catch(Exception e) {
        // 	system.debug(e); 
        // }
        // system.debug('*** createActivity start date = ' + startDate);

        // DateTime endDate=null;
        // try{
        // 	endDate = (activityMap.get('EndDate')=='' && activityMap.get('EndDate')==null) ? null : dateTime.valueOf(activityMap.get('EndDate'));
        // }catch(Exception e) {
        // 	system.debug(e); 
        // }
        
        // system.debug('*** createActivity end date = ' + endDate);
        
        // if(activityMap.get('sfdc Object Id')!= ''){
        //         system.debug('*** createActivity sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
        //         objectToUse = activityMap.get('sfdc Object Id');
        // }
        //  else
        // 	system.debug('*** createActivity sfdc Object Id is empty ' );
       
        // system.debug('*** createActivity for objectToUse ' + objectToUse);      
        
        // String prefix = '';
        // if(objectToUse != '')
        //     prefix = objectToUse.substring(0, 3);
        // system.debug('*** objectToUse prefix = '+prefix);
        
        // String description = activityMap.get('Comments');
       	// if (description == null )
        // {
        // 	system.debug('*** createActivity description is null, set it to empty ' );
        // 	description = '';
        // }
        // else{
        // 	system.debug('*** createActivity description = ' + description );
        // }
        
        /*
        Task t = new Task (
	          Type = 'Call',
	          Status = 'Completed',
	          Subject = subject,
	          CallDurationInSeconds = durationInSecs,            
	          //Start__c = startDate,  //If we want to use the start of the interaction
	          //End__c = endDate,  //If we want to use the end of the interaction
	          Description = description,	         
	          CallDisposition = activityMap.get('Disposition'),
	          CallObject = activityMap.get('GenesysId')
	        );  
	               
 		try{	         			
 			if(prefix == accountPrefix || prefix == casePrefix){
	          	system.debug('*** create task for account or case as the sfdcobjectId');
	           	system.debug('*** create task Related to - WhatId = ' + objectToUse);
	          	t.put('WhatId',objectToUse);
	        }
	        else{
	        	if(prefix == contactPrefix || prefix == leadPrefix){
	        		system.debug('*** create task for contact or lead as the sfdcobjectId');
	           		system.debug('*** create task Name - WhoId = ' + objectToUse);
	          		t.put('WhoId',objectToUse);
	        	}
	        }
	              
	        if(prefix == contactPrefix)
	        {
	        	//Following SOQL should not be causing issues with encryption	
	          	Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
	          	system.debug('*** create task for contact');
	          	system.debug('*** create task Related to - WhatId for conact.AccountId= ' + contact.AccountId);
	          	t.put('WhatId',contact.AccountId); 
	        }
	        
	        if (prefix == casePrefix && personAccountsEnabled == false)
	        {
	        	String contactId = findContactFromcase(objectToUse);
	        	if (contactId != null && contactId != '')
	        	{
	        		system.debug('*** create task Name - WhoId = ' + contactId);
	        		t.put('WhoId',contactId);
	        	}        		
	        }
	        
	        String caseId = activityMap.get('sfdcCaseId');
	        if(caseId != '')
	        {
	        	system.debug('*** case Id is exists');
	        	system.debug('*** create task Related to - WhatId is assigned as caseId = ' + caseId);
	        	t.put('WhatId',caseId);
	        }                  
	        String mySFDCfield = '';
	        String mySFDCvalue = '';
	        for (Integer index=1; index<=5; index++){
	        	if (activityMap.get('SFDC'+index+'field') != '' && (activityMap.get('SFDC'+index+'field') != null) && activityMap.get('SFDC'+index+'value') != '' && activityMap.get('SFDC'+index+'value') != null)
		        {
		            mySFDCfield = activityMap.get('SFDC'+index+'field');
		            mySFDCvalue = activityMap.get('SFDC'+index+'value');
		            system.debug('*** mySFDCfield ' + mySFDCfield + ' -- mySFDCvalue ' + mySFDCvalue);
		            t.put(mySFDCfield,mySFDCvalue);
		        }
	        }  
                            
        	insert t;
            
        }
        catch(QueryException e){
        	return result; 
        }
        system.debug('*** objectToUse Task id = '  +t.Id);
        result = t.Id;
        */
        return result;
     }
     




     //Get Task Desription
	@RemoteAction
	global static String getActivityComments(String taskID)
	{
		try {
           Task myTask = [SELECT Id, Description FROM Task WHERE Id = :taskID];            
           if(myTask != null) {           		
        		String comments = myTask.Description;     		
                system.debug('*** getActivityComment taskId = " + myTask.Id +  comments = ' +  myTask.Description);  
                return comments; 
           }
        } catch(QueryException e){
        	System.debug('*** An unexpected error has occurred: ' + e.getMessage());           
        }

       return '';
	}


 	//search for an activity by Genesys Interaction Id
 	@RemoteAction
    global static String findActivity(String connID)
    {
        system.debug('findActivity using  ' + connID);
        String returnValue = null; 
        if(connID == null)
        	return  returnValue;     
        try {
    		system.debug('findActivity using  current userId = ' + UserInfo.getUserId());
    		//For transfer/conference calls, each agent involved can create activities where CallObjects are the same but they are 
        	//assigned to differentusers(agents).  To see if a new activity should be create, make sure no activity with the same connId and assignee
        	//already exists.
        	
        	//The following SOQL should not be conflicting with encryption
           	List<Task> tasks = [SELECT Id FROM Task WHERE CallObject= :connID AND OwnerId = :UserInfo.getUserId()];            
           	if(tasks != null && !tasks.isEmpty()) {
           		system.debug('findActivity tasks size=  ' + tasks.size());
               	// return the first case found (should only be one)                            
               	for (Task t : tasks) {
               		 system.debug('findActivity return task Id=  ' + t.Id);
                   return t.Id;
               	} 
           }
        } catch(QueryException e){
        	system.debug('findActivity exception occurrred ' + e.getMessage());
            return returnValue; 
        }
        return returnValue; 
    }    
    
     // Update activity 
    @RemoteAction
    global static String updateActivity(String taskID,Map<String,String> activityMap)
    {
        system.debug('updateActivity using  taskID = ' + taskID);
        String returnValue = 'ERROR task Id ' + taskID +' not found';
        if(taskID == null)
        	return  returnValue; 
      	String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
        String taskPrefix = Schema.SObjectType.Task.getKeyPrefix(); 
        
        system.debug('*** updateActivity accountPrefix = ' + accountPrefix);
        system.debug('*** updateActivity contactPrefix = ' + contactPrefix);
        system.debug('*** updateActivity leadPrefix = ' + leadPrefix);
        system.debug('*** updateActivity casePrefix = ' + casePrefix);
        system.debug('*** updateActivity taskPrefix = ' + taskPrefix);
        
        try {
           Task myTask = [SELECT Id, Description FROM Task WHERE Id = :taskID];            
           if(myTask != null) {
           		//Comments, Call Result, Call Duration, Name, RelatedTo
           		string useWDEnotes = activityMap.get('Use WDE Notes');
        		system.debug('*** update task useWDEnotes: ' + useWDEnotes);
        		String comments = '';
        		
        		if (useWDEnotes == 'true' || useWDEnotes == 'True')
        			comments = activityMap.get('Comments');
        		else
        		{
        			//The comments are from Salesforce with addition of Email Desription and Chat/SMS transcripts at the end.
        			comments = myTask.Description;
        			if (comments != null && comments != '')
        				comments = comments + '\n' + activityMap.get('Comments');
        			else
        				comments = activityMap.get('Comments');
        		}
        		system.debug('*** update task comments: ' + comments);     
        		myTask.put('Description',comments);
        		String callDisposition = activityMap.get('Disposition');
        		myTask.put('CallDisposition',callDisposition);
        		String duration = activityMap.get('Call Duration');
        		Integer durationInSecs = Integer.valueOf(duration);
        		myTask.put('CallDurationInSeconds',durationInSecs);
        		
        		String objectToUse = '';
        		if(activityMap.get('sfdc Object Id')!= ''){
                	system.debug('*** update task  sfdc Object Id = ' + activityMap.get('sfdc Object Id'));
                	objectToUse = activityMap.get('sfdc Object Id');
        		}
        		String prefix = '';
        		if(objectToUse != '')
           			prefix = objectToUse.substring(0, 3);
        		system.debug('*** prefix = '+prefix);
        		if(prefix == accountPrefix || prefix == casePrefix){
          			system.debug('*** update task for account or case');
          			myTask.put('WhatId',objectToUse);
        		}
        		else{
          			if(prefix == contactPrefix || prefix == leadPrefix){
	        			system.debug('*** Update task for contact or lead as the sfdcobjectId');
	           			system.debug('*** Update task Name - WhoId = ' + objectToUse);
	          			myTask.put('WhoId',objectToUse);
        			}
        		}
              
		        if(prefix == contactPrefix)
		        {
		          Contact contact= [SELECT AccountId, Id FROM Contact WHERE Id= :objectToUse];
		          system.debug('*** Update task for contact');
		          myTask.put('WhatId',contact.AccountId); 
		        }
		        
		        if (prefix == casePrefix && personAccountsEnabled == false)
				{
					String contactId = findContactFromcase(objectToUse);
					if (contactId != null && contactId != '')
					{
						system.debug('*** Update task Name - WhoId = ' + contactId);
						myTask.put('WhoId',contactId);
					}        		
				}
		        
		        String caseId = activityMap.get('sfdcCaseId');
		        if(caseId != '')
		        	myTask.put('WhatId',caseId);

           		update myTask;
				returnValue = 'success';

           }
        } catch(DmlException e){
        	System.debug('*** An unexpected error has occurred: ' + e.getMessage());
            returnValue = 'ERROR An unexpected error has occurred: ' + e.getMessage();
        }
        return returnValue; 
    }      	
    
    
     
    @RemoteAction      
    global static String createCase(Map<String,String> caseMap)
    {        
        // system.debug('*** createCase');
        // String result = 'case not created';
        // String ixnType = caseMap.get('IXN Type');
        // String mediaType = caseMap.get('Media Type');
        // String subject = ixnType + ' ' + mediaType + ' ' + caseMap.get('DATE'); 
		
        // Case c = new Case (
        // 	Subject = subject,
        // 	Priority = 'Medium',
        // 	Origin = ixnType       	
        // );               
        
        // try{                        
        //         insert c;
        // }
        // catch(QueryException e){
        //          return result; 
        // }
        // system.debug('*** Case id = '  +c.Id);
        // result = c.Id;
		// return result;
		return '';
    }  
      
    @RemoteAction      
	global static String addAttachment(String objectId, String descriptionText, String nameText, String mimeType, Blob attachmentBody, String attachmentId)
    {        
        system.debug('***addAttachment objectId: ' + objectId + ' descriptionText: ' + descriptionText + ' nameText: ' + nameText + ' mimeType: ' + mimeType + 'attachmentId: '  + attachmentId);       
        try{           
 
   			    if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    
                    String newAttachmentBody = EncodingUtil.base64Encode(attachmentBody);                    
                    
                    newBody += newAttachmentBody;
                    
                    att.Body = EncodingUtil.base64Decode(newBody);
                    //att.Body = Blob.valueOf(newBody);                    
                    
                    if(attachmentId == null) {
                    	system.debug('*** First time through');
                        att.Name = nameText;
                        att.parentId = objectId;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'error';
                }
        }
        catch(QueryException e){
            system.debug('*** addAttachment error ' + e);
            return 'error';
        }
    }
    
	private static Attachment getAttachment(String attId) 
	{
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }

    @RemoteAction
   	global static Object findCaseObject(String searchFieldName, String searchFieldValue){
        system.debug('*** findCaseObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
        Object result = null;
        //This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        if(searchFieldName == '' || searchFieldValue == '')
			return result;
			
		List<List<SObject>> cObjects = null;
        String query;
        String lowerFieldName = searchFieldName.toLowerCase(); 
        try{
        	if ((lowerFieldName.length() > 8 && (lowerFieldName.substring(0,8) == 'account.' || lowerFieldName.substring(0,8) == 'contact.')) || 
        		(lowerFieldName.length() > 5 && lowerFieldName.substring(0,5) == 'lead.')){
	        	query = 'SELECT Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate FROM Case WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\'';
	        	system.debug('***findCaseObject:  Case query = ' + query);  
	        	List<Case> all_cases = Database.query(query);
	        	if (all_cases != null && !all_cases.isEmpty()){ 	        		 
	           		Integer listSize = all_cases.size();	           		
		        	system.debug('***findCaseObject:  Case Count = ' + listSize);
		        	result = all_cases;
	        	}
	        	else
	        		system.debug('***findCaseObject:  Case Count = 0');
	        }
	        else
	        {        	
	        	if (lowerFieldName != 'contactid' && lowerFieldName != 'casenumber' && lowerFieldName != 'subject' && 
	        		lowerFieldName != 'account.name' && lowerFieldName != 'contact.name' && lowerFieldName != 'createddate')
		           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Case(Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate, ' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
		        else
		        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Case(Id, ContactId, CaseNumber, Subject, Account.Name, Contact.Name, CreatedDate WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		         		
	           	system.debug('***findCaseObject: Case query = ' + query);   
	           	
	           	cObjects = search.query(query);
				if (cObjects != null){          
		           	List<Case> all_cases = ((List<Case>)cObjects[0]);		          
	           		if (all_cases != null && !all_cases.isEmpty()){ 
	           			Integer listSize = all_cases.size();
		        		system.debug('***findCaseObject: Case Count = ' + listSize);
		        		result = all_cases;
		        	}
		        	system.debug('***findCaseObject:  Case Count = 0');
				}
				else
	        		system.debug('***findCaseObject:  Case Count = 0');
	        }             
        }
        catch(QueryException e){
        	system.debug('*** QueryException ' + e); 
        }        
        return result;
    } 
 
    @RemoteAction
    global static Object findCaseObjectMapSearch(Map<String,String> searchMap, Boolean searchAllFields){
       system.debug('*** findCaseObjectMapSearch:  searchAllFields - ' + searchAllFields);	
        Integer totalCount = 0;
        List<Case> all_cases = new List<Case>();
        if (searchMap != null && searchMap.size() > 0){
	    	for (String mySFDCfield: searchMap.keySet())
	        {        	
	        	if (mySFDCfield != '' && mySFDCfield != null){
	        		String mySFDCvalue = searchMap.get(mySFDCfield); 
		        	if (mySFDCvalue != '' && mySFDCvalue != null)
		        	{
		        		system.debug('*** findCaseObjectMapSearch: searchFieldName - ' + mySFDCfield +', searchFieldValue - ' + mySFDCvalue );
		        		Object resultObj = findCaseObject(mySFDCfield,mySFDCvalue);
		        		if (resultObj != null)
		        		{
		        			List<Case> result = (List<Case>)resultObj;
		        			Integer listSize = result.size();
		        			system.debug('*** findCaseObjectMapSearch:  result size= ' + listSize);		        			
				          	if (listSize > 0){
					          	for (Case r: result){
					          		Boolean alreadyAdded = false;
					          		for(Case c: all_cases){
					          			if (r.Id == c.Id){
					          				alreadyAdded = true;
					          				break;
					          			}
					          		}
					          		if (alreadyAdded == false){
					          			all_cases.add(r);
					          		}
					          	}				          	    
			        			// If search till first result, stop the search 	  
			        			if  (searchAllFields == false)
			        			{
		        					system.debug('*** findCaseObjectMapSearch:  Found some result, stop the search');  
		        					break;    
		        				} 
				          	}    			
		        		}			         
		        	}
		        	else
		        		system.debug('*** findCaseObjectMapSearch: go on to next check');
	        	}
	        } //for loop
	        system.debug('*** findCaseObjectMapSearch: search completed');     
	        if (all_cases != null)
	        	system.debug('*** findCaseObjectMapSearch: all_cases.size() :' + all_cases.size()); 
	        return all_cases; 
        } 
        return null;   
    } 
            
 	@RemoteAction
    global static Object findObject(String searchFieldName, String searchFieldValue){
        system.debug('*** findObject: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue);
        Object result = null;
        Integer aListSize = 0, cListSize = 0, lListSize = 0;
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        List<List<SObject>> cObjects = null;
        List<List<SObject>> aObjects = null;
        List<List<SObject>> lObjects = null; 
        
        searchFieldName = searchFieldName.removeEnd('\"').removeStart('\"');
        searchFieldValue = searchFieldValue.removeEnd('\"').removeStart('\"');
        
        //This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return result;
        String query;
        String lowerFieldName = searchFieldName.toLowerCase();
        	
        //check account
        try{
        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	          		
           	system.debug('*** Account query = ' + query);            
           	aObjects = search.query(query);
			if (aObjects != null){          
	           	accounts =((List<Account>)aObjects[0]);		          
           	}    
          	
            if (accounts != null){
                aListSize = accounts.size();
                if(aListSize == 1){                   
                	system.debug('*** Found one account match');   
                    system.debug('***  Id = ' + accounts[0].Id);
                    system.debug('***  Name = '+ accounts[0].Name);
                    system.debug('*** Phone = '+ accounts[0].Phone);               
                }
            }
        }
        catch(Exception e){
        	system.debug('*** Exception account search' + e);
        }
        
        //check contact
        try{
        	
			if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'contact.name' && lowerFieldName != 'contact.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Contact(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	           		
           	system.debug('*** Contact query = ' + query);            
           	cObjects = search.query(query);
			if (cObjects != null){          
	           	contacts =((List<Contact>)cObjects[0]);		          
           	}         
	        if (contacts != null){
	            cListSize = contacts.size();
	            if(cListSize == 1){	           
	            	system.debug('*** Found one contact match');  	             
	                system.debug('***  Id = ' + contacts[0].Id);
	                system.debug('***  Name = '+ contacts[0].Name);
	                system.debug('*** Phone = '+ contacts[0].Phone);	
	            }
	        }
        }
        catch(Exception e){
        	system.debug('*** Exception ' + e); 
        }
        
        //check lead
        try{
        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'lead.name' && lowerFieldName != 'lead.phone')
	           	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	        else
	        	query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Lead(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	          
	        system.debug('*** Lead query = ' + query);            
           	lObjects = search.query(query);
			if (lObjects != null){          
	           	leads =((List<Lead>)lObjects[0]);		          
           	}
	        if (leads != null){
	            lListSize = leads.size();
	            if(lListSize == 1){
	            	system.debug('*** Found one lead match');  
	                system.debug('***  Id = ' + leads[0].Id);
	                system.debug('***  Name = '+ leads[0].Name);
	                system.debug('*** Phone = '+ leads[0].Phone);	                
	            }
	        }
        }
        catch(Exception e){
        	system.debug('*** Exception ' + e); 
        }
        
        
        Integer total = aListSize + cListSize + lListSize;
        system.debug('*** findObject total search result(s) = ' + total);
        
        if (total == 0)
        	return 'not found';
        else if (total == 1){
        	if (aListSize == 1)
        		return accounts[0];
        	else if (cListSize == 1)
        		return contacts[0];
        	else
        		return leads[0];
        }
        else 
        	return 'multiple found';   
    }
    
   //Overload function using Map of field/field values
    @RemoteAction
    global static Object findObjectMapSearch(Map<String,String> searchMap, Boolean searchAllFields ){
         Object result = null;
        Object singleResult = null;
        Integer totalCount = 0;
    	for (String mySFDCfield: searchMap.keySet())
        {
        	if (mySFDCfield != '' && mySFDCfield != null)
        	{
        		String mySFDCvalue = searchMap.get(mySFDCfield); 
	        	if (mySFDCvalue != '' && mySFDCvalue != null)
	        	{
	        		system.debug('*** findObjectMapSearch: mySFDCfield - ' + mySFDCfield +', mySFDCvalue - ' + mySFDCvalue);
	        		result = findObject(mySFDCfield,mySFDCvalue);
	        		if (result != null && result != 'not found')
	        		{
	        			if (result == 'multiple found')
	        				return result;
	        			else //only one found for the current field and field-value
	        			{
	        				//store in case result gets overwritten by not found in next field/fieldValue searches
	        				singleResult = result;  
	        				if  (searchAllFields == false)
	        					break;
	        				else{
	        					totalCount ++;
	        					
	        					if (totalCount > 1)
	        						return 'multiple found';
	        				}
	        			}     			
	        		}		         
	        	}
	        	else
	        		system.debug('*** findObjectMapSearch go on to next check');
	        	
        	}
        	
        }
        system.debug('*** findObjectMapSearch totalCount = ' + totalCount +  ' result = ' + result + ' singleResult = ' + singleResult);
        
        if (totalCount == 1)
        	return singleResult;
        else
        	return result;
    }
    
    @RemoteAction
    global static Object findObjectByType(String searchFieldName, String searchFieldValue, String searchObjectType){
    	system.debug('*** findObjectByType: searchFieldName - ' + searchFieldName +', searchFieldValue - ' + searchFieldValue +', searchObjectType - ' + searchObjectType);
 		
    	List<Account> account_results = new List<Account>();
    	
    	//This line is added for the Cipher Cloud user support
        searchFieldValue =  String.escapeSingleQuotes(searchFieldValue);
        
        if(searchFieldName == '' || searchFieldValue == '')
        	return account_results;     
       
       	String lowerFieldName = searchFieldName.toLowerCase();
        String query;
        if (personAccountsEnabled == false)
        {
	        try{
	        	if (lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone')
	           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone,' + searchFieldName + ' WHERE ' + searchFieldName  + ' = \'' + searchFieldValue + '\')';
	           	else
	           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone' + ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	           		
	           	system.debug('*** Account query = ' + query);            
	           	List<List<sObject>> searchList = search.query(query);
				if (searchList != null){          
		           	List<Account> accounts =((List<Account>)searchList[0]);
		            if (!accounts.isEmpty()){
		                Integer listSize = accounts.size();
		                system.debug('*** Account Count = ' + listSize);
		                if(listSize != 0){					
			            	account_results.addAll(accounts);
			            	return  account_results; //RETURN IF ANY RESULTS CAME
				        }
		            }
	           	}
	        }
	        catch(QueryException e){
	        	system.debug('*** QueryException ' + e);        	
	        }
        }  
        /*else
        {
	        try{	        	
	        	if (searchObjectType == 'personaccount'){	
	           		if(lowerFieldName != 'name' && lowerFieldName != 'phone'  && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone' && lowerFieldName != 'ispersonaccount' && lowerFieldName != 'personemail'){
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail,'+searchFieldName+' WHERE IsPersonAccount = true AND ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	           		}  
		           	else{
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, , IsPersonAccount, PersonEmail WHERE IsPersonAccount = true AND ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		           	}
	        	}
	        	else{ //Business and Person Account both
	       			if(lowerFieldName != 'name' && lowerFieldName != 'phone' && lowerFieldName != 'account.name' && lowerFieldName != 'account.phone' && lowerFieldName != 'ispersonaccount' && lowerFieldName != 'personemail')
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name,Phone, IsPersonAccount, PersonEmail,'+searchFieldName+ ' WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
		           	else
		           		query='FIND \'' + searchFieldValue + '\' IN ALL FIELDS RETURNING Account(Id, Name, Phone, IsPersonAccount, PersonEmail WHERE ' + searchFieldName + ' = \'' + searchFieldValue + '\')';
	   
	        	}
	        	system.debug('*** Account query = ' + query);  
	        	List<List<sObject>> searchList = search.query(query);
	           
	           	if (searchList != null){          
		           	List<Account> accounts =((List<Account>)searchList[0]);
		            if (!accounts.isEmpty()){
		                Integer listSize = accounts.size();
		                system.debug('*** Account Count = ' + listSize);
		                if(listSize != 0){					
			            	account_results.addAll(accounts);
			            	return  account_results; //RETURN IF ANY RESULTS CAME
				        }
		            }
	           	}
	        }
	        catch(QueryException e){
	        	system.debug('*** QueryException ' + e);        	
	        }
        }*/  
        return account_results;
    }  
    
    
    //Overload function using Map of field/field values
    @RemoteAction
    global static Object findObjectByTypeMapSearch(Map<String,String> searchMap, Boolean searchAllField, String searchObjectType){
   		system.debug('*** findObjectByTypeMapSearch: searchAllField - ' + searchAllField +', searchObjectType - ' + searchObjectType);
 	  	List<Account> account_results = new List<Account>();
    	for (String mySFDCfield: searchMap.keySet())
        {
        	if (mySFDCfield != '' && mySFDCfield != null){
        		String mySFDCvalue = searchMap.get(mySFDCfield); 
	        	if (mySFDCvalue != '' && mySFDCvalue != null)
	        	{
	        		system.debug('*** findObjectByTypeMapSearch: searchFieldName - ' + mySFDCfield +', searchFieldValue - ' + mySFDCvalue +', searchObjectType - ' + searchObjectType);
	        		Object resultObj = findObjectByType(mySFDCfield,mySFDCvalue, searchObjectType);
	        		if (resultObj != null)
	        		{
	        			List<Account> result =  (List<Account>)resultObj;
	        			Integer listSize = result.size();
	        			system.debug('*** findObjectByTypeMapSearch:  result size= ' + listSize);    
	        			if (listSize > 0){		        			
		        			for (Account r: result){
				          		Boolean alreadyAdded = false;
				          		for(Account ar: account_results){
				          			if (ar.Id == r.Id){
				          				alreadyAdded = true;
				          				break;
				          			}
				          		}
				          		if (alreadyAdded == false){
				          			account_results.add(r);
				          		}
				          	}
		        			// If search till first result, stop the search 	  
		        			if  (searchAllField == false)
		        			{
		        				system.debug('*** findObjectByTypeMapSearch:  Found some result, stop the search');  
		        				break;    
		        			} 		
	        			}	
	        		}		         
	        	}
	        	else
	        		system.debug('*** findObjectByTypeMapSearch: go on to next check');
        	}
        	
        } 
        system.debug('*** findObjectByTypeMapSearch: search completed');     
        return account_results;
    } 

    
      
    @RemoteAction
    global static String testConnection()
    {   
    	return 'Active';
    }


	/***
	*@Author : Francesco Imperioli
	*@Description : Check the existence of prefix field on Lead/Contact in order to give the correct number format for genesys
	**/
	@RemoteAction
	global static String getPrefixCompletePhoneNumber(Map<String,String> payload){

		String recordId = payload.get('recordId');
		String objectName = payload.get('objectType');
		String result = payload.get('number');

		String userLegalEntity = XC_UTIL_User.getLegalEntityFromUser();

		//TODO: check Metadata configuration for prefixes
		List<XC_CM_CTIConfiguration__mdt> CTIConfs = [SELECT XC_LegalEntity__c,XC_AllowInternationalPrefixes__c,XC_InternationalPrefix__c 
		FROM XC_CM_CTIConfiguration__mdt 
		WHERE XC_LegalEntity__c = :userLegalEntity LIMIT 1];

		//if international prefixes are not allowed, replace it and return
		if(!CTIConfs.isEmpty()){
			if(!CTIConfs[0].XC_AllowInternationalPrefixes__c){
				System.Debug('REMOVE INTERNATIONAL PREFIX ' + CTIConfs[0].XC_InternationalPrefix__c);
				result = result.replace(CTIConfs[0].XC_InternationalPrefix__c,'');
				System.Debug('REMOVE INTERNATIONAL PREFIX RESULT ' + result);
				return result;
			}
		}
		
		// if(objectName.equalsIgnoreCase('Lead')){
		// 	List<Lead> leadCalled = [SELECT XC_PhonePrefix__c FROM Lead WHERE Id = :recordId];
		// 	System.Debug('LEAD::: ' + leadCalled);
		// 	if(String.isNotBlank(leadCalled[0].XC_PhonePrefix__c)){
		// 		String prefixString = leadCalled[0].XC_PhonePrefix__c.replace('+','0');
		// 		result = result.replace(leadCalled[0].XC_PhonePrefix__c, prefixString);
		// 	}
		// }else if(objectName.equalsIgnoreCase('Contact')){
		// 	List<Contact> contactCalled = [SELECT XC_PhonePrefix__c FROM Contact WHERE Id = :recordId];
		// 	System.Debug('CONTACT::: ' + contactCalled);
		// 	if(String.isNotBlank(contactCalled[0].XC_PhonePrefix__c)){
		// 		String prefixString = contactCalled[0].XC_PhonePrefix__c.replace('+','0');
		// 		result = result.replace(contactCalled[0].XC_PhonePrefix__c, prefixString);
		// 	}
		// }else if(objectName.equalsIgnoreCase('XC_CTI_Interaction__c')){
		// 	List<XC_CTI_Interaction__c> interactionCalled = [SELECT XC_Customer_Phone_Prefix__c FROM XC_CTI_Interaction__c WHERE Id = :recordId];
		// 	System.Debug('CTI_INT::: ' + interactionCalled);
		// 	if(String.isNotBlank(interactionCalled[0].XC_Customer_Phone_Prefix__c)){
		// 		String prefixString = interactionCalled[0].XC_Customer_Phone_Prefix__c.replace('+','0');
		// 		result = result.replace(interactionCalled[0].XC_Customer_Phone_Prefix__c, prefixString);
		// 	}
		// }else if(objectName.equalsIgnoreCase('Account')){
		// 	List<Account> accountCalled = [SELECT XC_AccountPhonePrefix__c FROM Account WHERE Id = :recordId];
		// 	System.Debug('ACCOUNT ' + accountCalled);
		// 	if(String.isNotBlank(accountCalled[0].XC_AccountPhonePrefix__c)){
		// 		String prefixString = accountCalled[0].XC_AccountPhonePrefix__c.replace('+','0');
		// 		result = result.replace(accountCalled[0].XC_AccountPhonePrefix__c, prefixString);
		// 	}
		// }

		return  result;


	}

        
	//The method below is for the support of activating Mark Done and Call Result from Salesforce to Genesys WDE
    @AuraEnabled
    public static Sobject getRecords(Id recordId, String fieldsToShow) {
        String objectName = recordId.getSobjectType().getDescribe().getName();
        String soql = 'Select '+fieldsToShow+'  from ' + objectName + ' where Id = :recordId';
        Sobject rec = Database.query(soql);
        return rec;
	}
	
	/**
	 * @author francesco imperioli - fimperioli@deloitte.it
	 * @description create messages to invoke wde call recording - ITALY ONLY 
	 * @createddate 18/02/2020
	 */
	@RemoteAction
	global static Map<String,Object> getWDERecordingMessage(Map<String,Object> params,String mode){
		return XC_UTIL_CTICallRecording.generateRecordingMessage(params,mode);
	}

	/**
	 * @author francesco imperioli - fimperioli@deloitte.it
	 * @description manage inbound call recording url from wde phone bar
	 * @createddate 18/02/2020
	 */
	@RemoteAction
	global static Map<String,Object> manageWDERecordingURL(Map<String,Object> params){
		return XC_UTIL_CTICallRecording.manageInboundRecordingMessage(params);
	}

	/**
	 * @author francesco imperioli - fimperioli@deloitte.it
	 * @description commit a platform event to manage cti recording events
	 * @createddate 18/02/2020
	 */
	@RemoteAction
	global static Map<String,Object> createWDEToSfPlatformEvent(Map<String,Object> params){
		return XC_UTIL_CTICallRecording.publishStartStopRecordingEventMessage(params);
	}

	/**
	 * @author francesco imperioli - fimperioli@deloitte.it
	 * @description manage navigation events and show recording controls
	 * @createddate 18/02/2020
	 */
	@RemoteAction
	global static Map<String,Object> checkShowRecordingPanel(Map<String,Object> params){
		return XC_UTIL_CTICallRecording.checkShowRecordingPanelAndSendEvent(params);
	}



}