/** 
* ===================================================================================
* @className        ATCL_VFC032_ActionPlanAutoCreation 
* @description      Class for auto creation of action plans
* @author           IC
* @email            idelcampo@deloitte.es
* @version          V0.1
* @testClass        
* @dateCreated      2016/10/18
* @lastChange       2017/03/20 ACT: comments  
* ===================================================================================
*/
public with sharing class ATCL_VFC032_ActionPlanAutoCreation {
    public final static Boolean     DEBUGACTIVE = XC_UTIL_Debug.isActive('ATCL_VFC032_ActionPlanAutoCreation');
    
    public ActionPlan__c            actionPlan              { get; set; }
    public ActionPlansUtilities     actionPlans             { get; set; }
    public String                   templateId              { get; set; }
    public List<String>             relatedObjIds           { get; set; }
    public String                   relatedObjName          { get; set; }
    public List<String>             relatedObjNameList      { get; set; }
    public List<APTaskTemplate__c>  apTasksOrg ;    
    public List<APTaskTemplate__c>  apTasks;
    public List<APTTaskTemplate__c> aptTasks;
    public String                   refType                  { get; set; }
    public String                   refID                    { get; set; }

    /**
        @name           ATCL_VFC032_ActionPlanAutoCreation
        @description    constructor method
        @params         template, ref, relatedType
        @return         -
    **/
    public ATCL_VFC032_ActionPlanAutoCreation( Id template, String ref, String relatedType){
        
        //Set parameters
        this.relatedObjNameList = new List<String>();
        this.relatedObjIds = new List<String>();
        this.actionPlan = New ActionPlan__c();
        this.templateId = template; 
        this.refId = ref; 
        this.refType = relatedType;        
    }    

    /**
        @name           initNewActionPlanFromTemplate
        @description    Method that initalizes controller for creating a new Action Plan from a template
        @params         -
        @return         -
    **/
    public void initNewActionPlanFromTemplate(){
        
        initNewActionPlan();
        getTasks();
        List<ActionPlanTemplate__c> listAPT = [ select a.Id, a.Name, a.Description__c, a.LastModifiedDate,  
                                                        a.SkipWeekends__c, a.SkipDay__c from ActionPlanTemplate__c a 
                                                        where a.Id = : this.templateId ];
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'LIST APT: ' + listAPT);
        
        if (listAPT.size() > 0) {
            ActionPlanTemplate__c actionPlanTemplate = listAPT.get(0);                              
            this.actionPlan.Name                     = this.actionPlans.retrieveAPNameFromTemplate(actionPlanTemplate);
            this.actionPlan.Description__c           = actionPlanTemplate.Description__c;
            this.actionPlan.SkipWeekends__c          = actionPlanTemplate.SkipWeekends__c;
            this.actionPlan.SkipDay__c               = actionPlanTemplate.SkipDay__c; 
            this.actionPlan.Action_Plan_Template__c  = actionPlanTemplate.Id;
        }

    }
    
    /**
        @name           initNewActionPlan
        @description    Method that initalizes controller for creating a new Action Plan (called from initNewActionPlanTemplate)
        @params         -
        @return         -
    **/
    private void initNewActionPlan(){
        
        this.actionPlan.StartDate__c    = Date.today();
        this.actionPlans                = new ActionPlansUtilities( this.actionPlan );   

            if( refId != null ){    
               
                this.referedObjectInit();
            } 
    }

    /**
        @name           referedObjectInit
        @description    Method that sets the Refered object to Create New Action Plan 
        @params         -
        @return         -
    **/
    private void referedObjectInit(){
        
        String nameParam = '';
        String idsParam;
        
        if( this.refType != null ){
            nameParam        = String.escapeSingleQuotes(refType);
            idsParam         = String.escapeSingleQuotes(refId);
            
            if( idsParam != null && idsParam != '' ){
                this.relatedObjIds = idsParam.split(',');       
            }
        }
        
        retrieveNameRelatedObject(relatedObjIds,nameParam);
    }
    
    /**
        @name           referedObjectOwnerInit
        @description    Method that sets the owner list for each object that will be related to an Action Plan
        @params         -
        @return         -
    **/
    private void referedObjectOwnerInit(){
        
        String nameParam = '';
        String idsParam;
        
                       
                nameParam        = refType; 
                idsParam         = this.refID; 
                
                if( idsParam != null && idsParam != '' ){
                    this.relatedObjIds = idsParam.split(',');       
                }
            
 //           this.actionPlans.retrieveOwnersDataRelatedObject( relatedObjIds, nameParam );
    }
    
    /**
        @name           retrieveNameRelatedObject
        @description    Method that retrieve the names of related objects
        @params         relatedObjIds, relatedObjectName
        @return         -
    **/
    private void retrieveNameRelatedObject( List<String> relatedObjIds, String relatedObjectName ){
        
        /*if( 'Account'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Accounts';
            for( Account acc : [ Select Name from Account where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( acc.Name );
            }
        } 
        else if( 'Lead'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Leads';
            for( Lead lead : [ Select FirstName, LastName from Lead where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( (lead.FirstName != null) ? lead.FirstName + ' ' + lead.LastName : lead.LastName );
            }
        } 
        else if( 'Contact'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Contacts';
            for( Contact cont : [ Select LastName, FirstName from Contact where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( (cont.FirstName != null) ? cont.FirstName + ' ' + cont.LastName : cont.LastName );
            }
        } 
        else if( 'Opportunity'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Opportunities';
            for( Opportunity opp : [ Select Name from Opportunity where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( opp.Name );
            }
        }*/
        //Add new version Support to Cases , Contracts ans Campaigns
        if( 'Case'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Cases';
            for( Case cases : [ Select Subject, CaseNumber from Case where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( (cases.Subject != null) ?  cases.CaseNumber + ': ' + cases.Subject : cases.CaseNumber );
            }
        }
        
        /*else if( 'Campaign'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Campaigns';
            for( Campaign camp : [ Select Name from Campaign where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( camp.Name );
            }
        }
        
        else if( 'Contract'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'Contracts';
            for( Contract contr : [ Select ContractNumber from Contract where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( 'Contract Number :'+ contr.ContractNumber );
            }
        }*/
        //Add custom object code Segment here.
        /*else if( 'CustomObject'.equalsIgnoreCase( relatedObjectName ) ){
            this.relatedObjName = 'CustomObject';
            for( CustomObject custObj : [ Select Name from CustomObject where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( custObj.Name );
            }
        }*/
    }

    /**
    * Wrapper Class for AP task Object
    * @author Rodrigo Birriel
    * @createddate 08/01/2010
    */
    /*private class ApTaskWrapper{
        
        public APTaskTemplate__c task       { get; set; }
        public  Integer     position        { get; set; }
        public  Boolean     isLast          { get; set; }
        public  Boolean     displayLookUp   { get; set; }
        public  Boolean     userRequired    { get; set; }
        
        public ApTaskWrapper( APTaskTemplate__c apTask, Integer pos, Boolean looKp, Boolean userReq ){
            task            = apTask;
            position        = pos;
            isLast          = false;
            displayLookUp   = looKp;
            userRequired    = userReq;
        }
    }*/

    /**
    * Gets Tasks related to an Action Plan
    * @return apTasks
    */
    private void getTasks(){

        if( this.apTasks == null || this.apTasks.size() == 0 ) {
            if( this.templateId != null ){
                String tempApId = this.templateID; 
                 
                aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c, a.User__r.Name, a.Id, 
                                a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, a.APTTaskTemplate__r.Subject__c, 
                                a.Reminder__c, a.SendEmail__c, a.Comments__c, a.taskIndex__c
                                From APTTaskTemplate__c a
                                where a.Action_Plan_Template__c =: TempApId order by taskIndex__c ASC ];

                this.apTasks = new List<APTaskTemplate__c>();
                
                Action_Plans_Settings__c mySettings = this.actionplans.getCustomSetting();
                String userId; 
                for( APTTaskTemplate__c aptTask : aptTasks ){
                  //Read de Custom Settings in order to asign the User to that Task
                    if( aptTask.User__c != null ) { 
                       XC_UTIL_Debug.debug(DEBUGACTIVE, '############ userc != null');
                        userId = aptTask.User__c ; 
                    }
                    else if( aptTask.User__c == null && ( mySettings != null && !mySettings.Unassigned_Task_Default__c ) ) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '######## userc = null and custom setting = false');
                        userId = UserInfo.getUserId();
                    }
                    else if( aptTask.User__c == null && ( mySettings != null &&  mySettings.Unassigned_Task_Default__c ) ) {
                        //RSC 2011-05-27 This appears to be in error 
                        //results in an emtpy assign to field being populate with the current user's info
                        //userId = UserInfo.getUserId();//null;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '### get current user info');
                        userId = null;
                    } 

                    APTaskTemplate__c t   = new APTaskTemplate__c();
                    t.Type__c             = aptTask.Type__c;
                    t.Subject__c          = aptTask.Subject__c;
                    t.Priority__c         = aptTask.Priority__c;
                    t.Dependent__c        = aptTask.Dependent__c;
                    t.taskIndex__c      = aptTask.taskIndex__c;
                    t.Name                  = aptTask.Name;
                    t.DaysFromStart__c    = aptTask.DaysFromStart__c;
                    t.User__c             = userId;
                    t.Reminder__c         = aptTask.Reminder__c;
                    t.Minutes_Reminder__c  = this.actionplans.getReminderDefaultTime();
                    t.SendEmail__c        = aptTask.SendEmail__c;
                    t.Comments__c         = aptTask.Comments__c;
                    this.apTasks.add( t );
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'COMPRUEBO TASKS: ' +  this.apTasks);
            }
            
         }       
    }
 
    /**
    * Checks if Action Plan Tasks has cycling dependency.
    * @return exists
    */
    private Boolean checkCycleDependent(){
        System.debug('@@@@@@ checkCycleDependent - apTasks = '+this.apTasks );
        Boolean exists  = false;
        Integer index   = 0;
        if(this.apTasks <> null){
            for( APTaskTemplate__c t : this.apTasks ){
                if( t.Dependent__c != 'None' && t.Dependent__c != null ){
                    Integer tempIndex       = Integer.valueOf( t.Dependent__c );
                    APTaskTemplate__c link  = this.apTasks[tempIndex];
                    
                    
                    //task can not depend on themselves
                    if(tempIndex == index){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ERROR: A Task Cannot Depend on itself'); 
                        return true;
                    }
                    
                    
                    if( this.dependantCycle( t, link, index ) ){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ERROR: Task has dependency'); 
                        return true;
                    }
                }
            index++;
        }
        }
        
        return exists;
    }
    
    /**
    * Check for cyclic dependent tasks
    * @param originTask
    * @param destinyTask
    * @param index
    * @return Boolean 
    */
    private Boolean dependantCycle( APTaskTemplate__c originTask, APTaskTemplate__c destinyTask, Integer index ){
        
        System.debug('@@@ dependantCycle - originTask = '+originTask );
        System.debug('@@@ dependantCycle - destinyTask = '+destinyTask );
        System.debug('@@@ dependantCycle - index = '+index );
        Boolean hasDependency = false;
        Set<Integer> visitedTasks = new Set<Integer>();
        
        while( !hasDependency ){
            
            if (destinyTask.Dependent__c != 'None'){
                if (visitedTasks.contains(Integer.valueOf( destinyTask.Dependent__c ))){
                    hasDependency = true;
                    break;
                }else{
                    visitedTasks.add(Integer.valueOf( destinyTask.Dependent__c ));
                }
            }
            
             if( destinyTask.Dependent__c != 'None' && destinyTask.Dependent__c != null  ){
                Integer tempIndexDestiny    = Integer.valueOf( destinyTask.Dependent__c );
                APTaskTemplate__c link      = this.apTasks[ tempIndexDestiny ];
                
                if( link.Dependent__c != 'None' ){
                    if( Integer.valueOf( link.Dependent__c ) == index ){
                        hasDependency = true;
                        break;
                    }
                    else{
                        //get Next task in dependency chain
                        Integer tempIndex   = Integer.valueOf( destinyTask.Dependent__c );
                        destinyTask         = this.apTasks[ tempIndex ];
                    }   
                }
                else{
                    break;
                }
             }else{
                break;
             }
        }

        return hasDependency;
    }    

    /**
    * Action which saves a new Action Plan
    */
    public void save(){
        
               
        try{
            if( !this.checkCycleDependent() ){
                referedObjectOwnerInit();
                this.saveHandler();   
            }
        }
        catch( FieldCustomValidationException e ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'FieldCustomValidationException: '+ e.getCustomMessage()); 
        }
        catch( DmlException e ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'DmlException - There was an error saving - ' + e);
        }
        
        
    }
    
    /**
    * Saves Action Plan Handler.
    * @return Pagereference called Method
    */
    private Void saveHandler(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### CALL saveHandler');
        String oIds = refId;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### saveHandler - refId='+refId);
        List<String> oIdsList = new List<String>();

        if( oIds != null ){

            oIdsList = oIds.split(',');

            if(oIdsList.size() > 1){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRO EN SAVEMULTIPLE');
                this.saveMultiple(); 
            }else{
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRO EN SAVEAP');
                this.saveAP();  
            }
                    
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRO EN SAVEAP - 2');
            this.saveAP();
        }
    }  
    
    /**
    * Save Action Plans for Multiple Related Object Instances.
    * Invokes batch process that creates : ActionPlan, ActionPlanTasksTemplate and Tasks 
    * @return Pagereference
    */
    private Void saveMultiple(){
        
        String oName                    = refType;
        String oIds                     = refId;
        List<ActionPlan__c> apList      = new List<ActionPlan__c>();
        List<APTaskTemplate__c> aptList = new List<APTaskTemplate__c>();
        Savepoint sp = Database.setSavepoint();
        
        if( ( oName != null || oName != '' ) && ( oIds != null || oIds != '' ) ){
            try{
                 
                List<String> oIdsList = oIds.split(',');
                //Now for each inserted AP we should run through tasks and create them
                this.apTasksOrg = new List<APTaskTemplate__c>();
                this.apTasksOrg.addAll( this.apTasks );
                this.apTasks.clear();        
                
                ActionPlansBatchBuilder taskBatch = new ActionPlansBatchBuilder(this.actionPlan,this.apTasksOrg, oName,oIdsList);
                
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'taskBatch => ' + taskBatch);
                taskBatch.execute(null,null);
                //Database.ExecuteBatch( taskBatch );
                
            }catch(Exception e){
                
                Database.rollback( sp );    
                
            }
        }
                           
    }

    /**
    * Saves Action Plan Instance and task. Also creates all due dates for tasks, then redirects to the AP list
    */
    private Void saveAp(){

        String actionPlanId ;
        String objId;
        String objName;
        List<String> oIdsList   = new List<String>();
        Savepoint sp = Database.setSavepoint();  
        
        objName = refType;
        objId   = refId;
        oIdsList= objId.split(',');

        if( ( objName != null || objName != '' ) && ( oIdsList.size() == 1 ) ){
            try{  
                //Now for each inserted AP we should run through tasks and create them
                this.apTasksOrg = new List<APTaskTemplate__c>();
                if(this.apTasks!=null){
                    this.apTasksOrg.addAll( this.apTasks );
                    this.apTasks.clear();
                    
                    if (actionPlan.Id == null){
                        ActionPlansBatchBuilder taskBatch = new ActionPlansBatchBuilder(this.actionPlan,this.apTasksOrg, objName,oIdsList);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'TASKBATCH 1: ' + taskBatch);
                        //Database.ExecuteBatch( taskBatch );
                        taskBatch.execute(null, null);
                    }else{
                        ActionPlansBatchBuilderUtilities taskBatch = new ActionPlansBatchBuilderUtilities(this.actionPlan,this.apTasksOrg, objName,oIdsList);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'TASKBATCH 2: ' + taskBatch);
                        taskBatch.generateActionPlans();
                        actionPlanId = taskBatch.getNewActionPlanId(); 
                    }     
                }


            }catch( exception e ){
                Database.rollback( sp );   
                throw e;
            }
        }
    }
}