/**
 * Created by RGAROFALO00 on 26/03/2020.
 */

@IsTest
public class TestDataFactory {
    public static Double initException() {
        Double d;
        try {
            d = Math.sqrt(-4);
        } catch (MathException e) {
            //
        }
        return d;
    }

    public static String initNote() {
        String note = 'Some Note';
        return note;
    }

    public static String initRequest() {
        String request = 'Fake request';
        return request;
    }

    public static String initResponse() {
        String response = 'Fake response';
        return response;
    }

    public static String initClassName() {
        String className = 'TestDataFactory';
        return className;
    }

    public static String initDebugType() {
        String debugType = 'Warning';
        return debugType;
    }

    public static String initMethodName() {
        String methodName = 'createEvent';
        return methodName;
    }

    public static String initMessage() {
        String message = 'Some message text';
        return message;
    }
    public static List<Structure__c> listMacroStructures (){
        List <Structure__c> listStructures = new List<Structure__c>();
        insertNameOrgRecordMap();
        Structure__c objStructure = new Structure__c();
        Structure__c objStructure2 = new Structure__c();
        Structure__c objStructure3 = new Structure__c();
        Structure__c objStructure4 = new Structure__c();
        Datetime nowDatetime = Datetime.now();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        Id RecordTypeIdStructure = Schema.SObjectType.Structure__c.getRecordTypeInfosByDeveloperName().get('Macrostructure').getRecordTypeId();//get only macrostructure RT
        objStructure.Name = 'Macrostruttura';
        objStructure.StructureType__c = 'A';
        objStructure.Address_Type__c = 'Via';
        objStructure.Address_Structure__c = 'Indirizzo';
        objStructure.Number_Address__c = '20';
        objStructure.PrimaryPhone__c = '0667104490';
        objStructure.StructureEmail__c = 'test@test.com' ;
        objStructure.Name_Org_Type__c = 'A';
        objStructure.ExtendedName__c = 'test';
        objStructure.LastModifiedWSO2__c = yesterdayDatetime ;
        objStructure.RecordTypeId = RecordTypeIdStructure;
        listStructures.add(objStructure);
        objStructure2.Name = 'MacrostrutturaA';
        objStructure2.StructureType__c = 'A';
        objStructure2.Address_Type__c = 'Via';
        objStructure2.Address_Structure__c = 'Indirizzo';
        objStructure2.Number_Address__c = '20';
        objStructure2.PrimaryPhone__c = '0667104490';
        objStructure2.StructureEmail__c = 'test@test.com' ;
        objStructure2.Name_Org_Type__c = 'A';
        objStructure2.ExtendedName__c = 'test';
        objStructure2.IsDeleted__c = true;
        objStructure2.LastModifiedWSO2__c = yesterdayDatetime ;
        objStructure2.IsDeleted__c = true;
        objStructure2.RecordTypeId = RecordTypeIdStructure;
        listStructures.add(objStructure2);
        objStructure3.Name = 'MacrostrutturaB';
        objStructure3.StructureType__c = 'A';
        objStructure3.Address_Type__c = 'Via';
        objStructure3.Address_Structure__c = 'Indirizzo';
        objStructure3.Number_Address__c = '20';
        objStructure3.PrimaryPhone__c = '0667104490';
        objStructure3.StructureEmail__c = 'test@test.com' ;
        objStructure3.Name_Org_Type__c = 'A';
        objStructure3.ExtendedName__c = 'test';
        objStructure3.IsDeleted__c = true;
        objStructure3.LastModifiedWSO2__c = oneWeekAgo ;
        objStructure3.RecordTypeId = RecordTypeIdStructure;
        objStructure3.IsDeleted__c = true;
        listStructures.add(objStructure3);
        objStructure4.Name = 'MacrostrutturaC';
        objStructure4.StructureType__c = 'A';
        objStructure4.Address_Type__c = 'Via';
        objStructure4.Address_Structure__c = 'Indirizzo';
        objStructure4.Number_Address__c = '20';
        objStructure4.PrimaryPhone__c = '0667104490';
        objStructure4.StructureEmail__c = 'test@test.com' ;
        objStructure4.Name_Org_Type__c = 'A';
        objStructure4.ExtendedName__c = 'test';
        objStructure4.IsDeleted__c = true;
        objStructure4.LastModifiedWSO2__c = oneWeekAgo ;
        objStructure4.RecordTypeId = RecordTypeIdStructure;
        objStructure4.Logical_Delete_Time__c = Datetime.now().addDays(-6);
        listStructures.add(objStructure4);

        insert listStructures;
        return listStructures;

    }
    public static List<Structure__c> listStructures (){
        List <Structure__c> listStructures = new List<Structure__c>();
        Structure__c objStructure = new Structure__c();
        Datetime nowDatetime = Datetime.now();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        //Id RecordTypeIdStructure = Schema.SObjectType.Structure__c.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        RecordType rc1 = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Structure__c' AND DeveloperName = 'Service' LIMIT 1];
        objStructure.Name = 'Ufficio';
        objStructure.StructureType__c = 'A';
        objStructure.Address_Type__c = 'Via';
        objStructure.Address_Structure__c = 'Indirizzo';
        objStructure.Number_Address__c = '20';
        objStructure.PrimaryPhone__c = '0667104490';
        objStructure.StructureEmail__c = 'test@test.com' ;
        objStructure.Name_Org_Type__c = 'F';
        objStructure.ExtendedName__c = 'test';
        objStructure.LastModifiedWSO2__c = yesterdayDatetime ;
        objStructure.RecordTypeId = rc1.Id;
        listStructures.add(objStructure);

        insert listStructures;
        return listStructures;

    }
    public static void insertNameOrgRecordMap(){
        List<NameOrgRecordMap__c> nameOrgRecordMaps = new List<NameOrgRecordMap__c>();
        NameOrgRecordMap__c nameOrgRecordMap = new NameOrgRecordMap__c();
        NameOrgRecordMap__c nameOrgRecordMap2 = new NameOrgRecordMap__c();
        nameOrgRecordMap.Name = 'G';
        nameOrgRecordMap.RecordType__c = 'Macrostructure2';
        nameOrgRecordMap2.Name = 'E';
        nameOrgRecordMap2.RecordType__c = 'DirectionF';
        nameOrgRecordMaps.add(nameOrgRecordMap2);
        nameOrgRecordMaps.add(nameOrgRecordMap);
        insert nameOrgRecordMaps;
    }

    public static List<Employee__c> listEmployee(){
        List <Employee__c> listEmployees = new List<Employee__c>();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        Employee__c objEmployee = new Employee__c();
        Employee__c objEmployee2 = new Employee__c();
        Employee__c objEmployee3 = new Employee__c();
        Employee__c objEmployee4 = new Employee__c();
        Employee__c objEmployee5 = new Employee__c();
        objEmployee.FirstName__c = 'Test';
        objEmployee.Surname__c = 'Test';
        objEmployee.SerialNumber__c = '1234TestClass';
        objEmployee.LastModifiedWSO2__c = yesterdayDatetime;
        objEmployee2.FirstName__c = 'Test1';
        objEmployee2.Surname__c = 'Test1';
        objEmployee2.SerialNumber__c = '12345TestClass';
        objEmployee2.IsDeleted__c = true;
        objEmployee2.LastModifiedWSO2__c = yesterdayDatetime;
        objEmployee3.FirstName__c = 'Test2';
        objEmployee3.Surname__c = 'Test2';
        objEmployee3.SerialNumber__c = '12342TestClass';
        objEmployee3.LastModifiedWSO2__c = oneWeekAgo;
        objEmployee3.IsDeleted__c = true;
        objEmployee4.FirstName__c = 'JENKINS';
        objEmployee4.Surname__c = 'User';
        objEmployee4.SerialNumber__c = 'JENKUSER';
        objEmployee4.LastModifiedWSO2__c = oneWeekAgo;
        objEmployee4.IsDeleted__c = false;
        objEmployee5.FirstName__c = 'Test0';
        objEmployee5.Surname__c = 'Test0';
        objEmployee5.SerialNumber__c = '1230TestClass';
        objEmployee5.LastModifiedWSO2__c = yesterdayDatetime;
        objEmployee5.Logical_Delete_Time__c = Datetime.now().addDays(-6);
        objEmployee5.IsDeleted__c = true;
        objEmployee5.Email__c = 'test@test.com';

        listEmployees.add(objEmployee);
        listEmployees.add(objEmployee2);
        listEmployees.add(objEmployee3);
        listEmployees.add(objEmployee4);
        listEmployees.add(objEmployee5);
        insert listEmployees;
        return listEmployees;
    }

    public static List<Employee__c> listEmployeeSingle(){
        List <Employee__c> listEmployees = new List<Employee__c>();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        Employee__c objEmployee = new Employee__c();

        objEmployee.FirstName__c = 'Test';
        objEmployee.Surname__c = 'Test';
        objEmployee.SerialNumber__c = '1235TestClass';
        objEmployee.LastModifiedWSO2__c = yesterdayDatetime;

        listEmployees.add(objEmployee);

        insert listEmployees;
        return listEmployees;
    }

    public static List<Role__c> listAllRoles (List<Structure__c> listStructures, List<Employee__c>listEmployees){
        List<Role__c> listRoles = new List<Role__c>();
        for(Structure__c structure : listStructures){
            for(Employee__c employee : listEmployees){
                Role__c objRole = new Role__c();
                objRole.StructureId__c = structure.Id;
                objRole.EmployeeId__c = employee.Id;
                listRoles.add(objRole);
            }
        }
        insert listRoles;
        return listRoles;

    }
    public static List<MacrostructureAssociation__c> listMacrostructureAssociations (List<Structure__c> listStructures, String userId){
        List<MacrostructureAssociation__c> listMas = new List<MacrostructureAssociation__c>();
        for(Structure__c structure : listStructures){
            MacrostructureAssociation__c objMa = new MacrostructureAssociation__c();
            objMa.User__c = userId;
            objMa.Structure__c = structure.Id;
            listMas.add(objMa);
        }
        insert listMas;
        return listMas;

    }

    public static List<Role__c> listRole (){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List <Employee__c> listEmployees = [SELECT Id FROM Employee__c];
        if(listEmployees.isEmpty() || listEmployees == null){
            listEmployees = listEmployee();
        }

        List<Role__c> listRoles = new List<Role__c>();

        Role__c objRole = new Role__c();
        objRole.StructureId__c = listStructures[0].Id;
        objRole.EmployeeId__c = listEmployees[0].Id;

        listRoles.add(objRole);
        insert listRoles;
        return listRoles;
    }

    public static List<Role__c> listRoles (List<Structure__c> listStructures, List<Employee__c>listEmployees){

        List<Role__c> listRoles = new List<Role__c>();
        Datetime nowDatetime = Datetime.now();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        Role__c objRole = new Role__c();
        Role__c objRole1 = new Role__c();
        Role__c objRole2 = new Role__c();
        Role__c objRole3 = new Role__c();
        objRole.StructureId__c = listStructures[0].Id;
        objRole.EmployeeId__c = listEmployees[0].Id;
        objRole.LastModifiedWSO2__c = nowDatetime;
        objRole1.StructureId__c = listStructures[1].Id;
        objRole1.EmployeeId__c = listEmployees[1].Id;
        objRole1.LastModifiedWSO2__c = yesterdayDatetime;
        objRole1.IsDeleted__c = false;
        objRole2.StructureId__c = listStructures[2].Id;
        objRole2.EmployeeId__c = listEmployees[2].Id;
        objRole2.LastModifiedWSO2__c = oneWeekAgo;
        objRole2.IsDeleted__c = true;
        objRole3.StructureId__c = listStructures[3].Id;
        objRole3.EmployeeId__c = listEmployees[3].Id;
        objRole3.LastModifiedWSO2__c = oneWeekAgo;
        objRole3.IsDeleted__c = true;
        objRole3.Logical_Delete_Time__c = Datetime.now().addDays(-6);

        listRoles.add(objRole);
        listRoles.add(objRole1);
        listRoles.add(objRole2);
        listRoles.add(objRole3);
        insert listRoles;
        return listRoles;
    }

    public static List<Role__c> listRoleSingle(List<Structure__c> listStructures, List<Employee__c>listEmployees){

        List<Role__c> listRoles = new List<Role__c>();
        Datetime nowDatetime = Datetime.now();
        Datetime yesterdayDatetime = Datetime.now().addDays(-1);
        Datetime oneWeekAgo = Datetime.now().addDays(-7);
        Role__c objRole = new Role__c();
        objRole.StructureId__c = listStructures[0].Id;
        objRole.EmployeeId__c = listEmployees[0].Id;
        objRole.LastModifiedWSO2__c = nowDatetime;

        listRoles.add(objRole);

        insert listRoles;
        return listRoles;
    }

    public static List<Weekly_Schedule__c> createWeeklySchedule(List<Structure__c> structures){
        List<Weekly_Schedule__c> weeklySchedules = new List<Weekly_Schedule__c>();
        for(Structure__c structure: structures){
            System.debug('@@@ RT '+structures[0].RecordTypeId);
            Weekly_Schedule__c weeklySchedule = new Weekly_Schedule__c();
            weeklySchedule.Structure_Reference__c = structure.Id;
            weeklySchedule.Day__c = 'Lunedì';
            weeklySchedules.add(weeklySchedule);
            weeklySchedule.All_Morning_Closed__c = true;
            weeklySchedule.All_Afternoon_Closed__c = true;
        }
        insert weeklySchedules;
        return  weeklySchedules;
    }

    public static User createUser() {
        User u = new User();
        u.LastName = 'Admin';
        u.Email = 'test1@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testRomaCapitale@test.com';
        u.CommunityNickname = 'test121';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.IsActive = true;
        u.SerialNumber__c = '1234TestClass';

        insert u;
        return u;
    }

    public static List<User> createWSOUsers(){
        List<User> users = new List<User>();

        User u = new User();
        u.LastName = 'Admin';
        u.Email = 'test1@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testRomaCapitale@test.com';
        u.CommunityNickname = 'test121';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'WSO2 Integration'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.IsActive = true;
        u.SerialNumber__c = '1234TestClass';

        User u2 = new User();
        u2.LastName = 'Integrator';
        u2.Email = 'test2@test.com';
        u2.Alias = 'Tcode1';
        u2.Username = 'test1RomaCapitale@test.com';
        u2.CommunityNickname = 'test111';
        u2.LocaleSidKey = 'en_US';
        u2.TimeZoneSidKey = 'GMT';
        u2.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'WSO2 Integration'].Id;
        u2.LanguageLocaleKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.IsActive = true;
        u2.SerialNumber__c = '1235TestClass';

        users.add(u);
        users.add(u2);

        insert users;
        return users;
    }

    public static User createUserWithRoleLeaderCC(){

        User u = new User();
        u.LastName = 'Admin';
        u.Email = 'test1@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testRomaCapitale@test.com';
        u.CommunityNickname = 'test121';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.IsActive = true;
        u.SerialNumber__c = '1234TestClass';
        u.UserRoleId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'LeaderCC'].Id;
        u.UserPermissionsKnowledgeUser = true;

        insert u;
        return u;
    }

    public static User createAnotherUserWithRoleLeaderCC(){

        User u = new User();
        u.LastName = 'Admin2';
        u.Email = 'test2@test.com';
        u.Alias = 'Tcode2';
        u.Username = 'testRomaCapitale2@test.com';
        u.CommunityNickname = 'test122';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'URP'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.IsActive = true;
        u.SerialNumber__c = '1235TestClass';
        u.UserRoleId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'LeaderCC'].Id;
        u.UserPermissionsKnowledgeUser = true;

        insert u;
        return u;
    }

    public static User createURPUser (){

        User u = new User();
        u.LastName = 'URP';
        u.Email = 'test1@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testRomaCapitaleURP@test.com';
        u.CommunityNickname = 'test121URP';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = [SELECT Id, Name FROM Profile WHERE Name LIKE '%urp%' LIMIT 1].Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.IsActive = true;
        u.SerialNumber__c = '1230TestClass';

        insert u;
        return u;
    }

    public static List<Knowledge__kav> createKnowledgeNews (){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('News').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.ExpirationDate__c = Date.today();
        objKnowledgeKav.Abstract__c = 'Test News';
        objKnowledgeKav.Title = 'News';
        objKnowledgeKav.Body__c = 'Body News';
        objKnowledgeKav.UrlName = 'News932749832';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        System.debug('list ' + listKnowlKavs);

        insert listKnowlKavs;
        return listKnowlKavs;
    }

    public static List<Knowledge__kav> createKnowledgeNewsFromStructures (List<Structure__c> listStructures){
        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('News').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.ExpirationDate__c = Date.today();
        objKnowledgeKav.Abstract__c = 'Test News';
        objKnowledgeKav.Title = 'News';
        objKnowledgeKav.Body__c = 'Body News';
        objKnowledgeKav.UrlName = 'News932749832';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        System.debug('list ' + listKnowlKavs);

        insert listKnowlKavs;
        return listKnowlKavs;
    }

    public static List<Knowledge__kav> createKnowledgeInternalFAQ (){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('FAQ_internal').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.Answer__c = 'risposta';
        objKnowledgeKav.Abstract__c = 'Test FAQ Interna';
        objKnowledgeKav.Title = 'Test FAQ Interna';
        objKnowledgeKav.Body__c = 'Body FAQ Interna';
        objKnowledgeKav.Question__c = 'Domanda FAQ Interna';
        objKnowledgeKav.UrlName = 'Interna';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        Database.SaveResult[] srList = Database.insert(listKnowlKavs);
        System.debug('@@@ srList '+srList);
        for(Database.SaveResult sr : srList){
            String recordId = sr.getId();
            System.debug('@@@ query '+[SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: recordId] );
        }
        return listKnowlKavs;
    }

    public static List<Knowledge__kav> createKnowledgeExternalFAQ (){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('FAQ_external').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.Answer__c = 'risposta';
        objKnowledgeKav.Abstract__c = 'Test FAQ Interna';
        objKnowledgeKav.Title = 'Test FAQ Interna';
        objKnowledgeKav.Question__c = 'Domanda FAQ Interna';
        objKnowledgeKav.UrlName = 'Interna';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        insert listKnowlKavs;
        return listKnowlKavs;
    }

    public static List<Knowledge__kav> createKnowledgeProvisionsCC(){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Disposizioni_CC').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.ExpirationDate__c =  Date.today();
        objKnowledgeKav.Abstract__c = 'Test ProvisionsCC';
        objKnowledgeKav.Title = 'Test ProvisionsCC';
        objKnowledgeKav.ThematicArea__c = 'Ambiente';
        objKnowledgeKav.Body__c = 'body';
        objKnowledgeKav.UrlName = 'CC';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        insert listKnowlKavs;
        return listKnowlKavs;
    }

    public static List<Knowledge__kav> createKnowledgeServiceCard(){
        List<Structure__c> listStructures = [SELECT Id FROM Structure__c];
        if(listStructures.isEmpty() || listStructures == null){
            listStructures = listMacroStructures();
        }

        List<Knowledge__kav> listKnowlKavs = new List<Knowledge__kav>();

        Id RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Schede_Servizio').getRecordTypeId();

        Knowledge__kav objKnowledgeKav = new Knowledge__kav();
        objKnowledgeKav.RecordTypeId = RecordTypeId;
        objKnowledgeKav.Abstract__c = 'Test FAQ Interna';
        objKnowledgeKav.Title = 'Test FAQ Interna';
        objKnowledgeKav.Who__c = 'who';
        objKnowledgeKav.How__c = 'how';
        objKnowledgeKav.Laws__c = 'laws';
        objKnowledgeKav.UrlName = 'ServiceCard';
        objKnowledgeKav.ContactEmail__c = 'test@test.com';
        objKnowledgeKav.MacrostructureReference__c = listStructures[0].Id;

        listKnowlKavs.add(objKnowledgeKav);

        insert listKnowlKavs;
        return listKnowlKavs;
    }
    public static WSO2Keys__c createWSO2Keys(){
        WSO2Keys__c wso2k = new WSO2Keys__c();
        wso2k.Name = 'Test';
        wso2k.Consumer_Key__c = 'testConsumerKey';
        wso2k.Consumer_Secret__c = 'testConsumerSecret';
        insert wso2k;
        return wso2k;
    }
    public static Account createAccount(){
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Test';
        acc.Fiscal_Code__pc = 'PSDSRA37A61H501R';
        insert acc;
        return acc;
    }
    public static Account createAccountWithParams(String fiscalCode){
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Test';
        acc.Fiscal_Code__pc = fiscalCode;
        insert acc;
        return acc;
    }
    public static List<Group> createGroups() {
        List<Group> groups = new List<Group>();

        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'ABC';
        testGroup.Type = 'Regular';

        Group testGroup1 = new Group();
        testGroup1.Name = 'AMA LINEA VERDE';
        testGroup1.DeveloperName = 'AMA_LINEA_VERDE';

        Group testGroup2 = new Group();
        testGroup2.Name = 'ROMA MOBILITA – ZTL DISABILI';
        testGroup2.DeveloperName = 'ROMA_MOBILITA_ZTL_DISABILI';

        Group queueGroup = new Group();
        queueGroup.Name = 'TestGroup';
        queueGroup.DeveloperName = 'TestGroup';
        queueGroup.Type = 'Queue';

        Group poliziaGroup = new Group();
        poliziaGroup.Name = 'COMANDO POLIZIA LOCALE';
        poliziaGroup.DeveloperName = 'POLIZIA_LOCALE_CENTRALE_OPERATIVA';

        groups.add(testGroup);
        groups.add(testGroup1);
        groups.add(testGroup2);
        groups.add(queueGroup);
        groups.add(poliziaGroup);

        insert groups;
        return groups;
    }

    public static List<Group> createParentGroups() {
        List<Group> groups = new List<Group>();

        Group testGroup = new Group();
        testGroup.Name = 'test';
        testGroup.DeveloperName = 'test';
        testGroup.Type = 'Regular';

        groups.add(testGroup);

        insert groups;
        return groups;
    }

    public static List<Account> createAccounts() {
        List<Account> accounts = new List<Account>();
        RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=TRUE LIMIT 1];

        Account acc = new Account();
        acc.LastName = 'test';
        acc.FirstName = 'test';
        acc.Gender__pc = 'M';
        acc.PersonBirthdate = Date.newInstance(1988,02,22);
        acc.Birthday_Nation__pc = 'Italia';
        acc.Birthday_Place__pc = 'Siena';
        acc.Birthday_Zone__pc = 'Siena';
        acc.Fiscal_Code__pc = 'SLRMCL77S60H501D';
        acc.Privacy_Newsletter__pc = true;
        acc.Privacy_Profiling__pc = true;
        acc.Privacy_Personal_Data__pc = true;
        acc.Date_Privacy_Newsletter__pc = System.today() - 400;
        acc.Date_Privacy_Profiling__pc = System.today() - 400;
        acc.Date_Privacy_Personal_Data__pc = System.today() - 400;
        acc.RecordTypeId = personAccountRecordType.Id;

        Account accExternal = new Account();
        accExternal.LastName = 'test';
        accExternal.FirstName = 'test';
        accExternal.Gender__pc = 'M';
        accExternal.PersonBirthdate = Date.newInstance(1988,02,22);
        accExternal.Birthday_Nation__pc = 'India';
        accExternal.Birthday_Place__pc = 'AP';
        accExternal.Birthday_Zone__pc = 'Estero';
        accExternal.Fiscal_Code__pc = 'RLRMCL77S60H501X';

        accounts.add(acc);
        accounts.add(accExternal);

        insert accounts;
        return accounts;
    }

    public static List<Account> createBusinessAccounts() {
        List<Account> accounts = new List<Account>();

        Account accNP = new Account();
        accNP.Email_Account__c = 'company@t.it';
        accNP.Partita_IVA__c = '01241241241';
        accNP.Name = 'Test Company';

        accounts.add(accNP);

        insert accounts;
        return accounts;
    }

    public static List<Contact> createContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();

        Contact con = new Contact();
        con.AccountId = accounts[0].Id;
        con.LastName =  'Tester';
        con.Fiscal_Code_contact__c = '12345';
        con.Persona_Fisica__c = accounts[0].Id;

        contacts.add(con);

        insert contacts;
        return contacts;
    }

    public static List<Contact> createBusinessContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();

        Contact con = new Contact();
        con.AccountId = accounts[0].Id;
        con.Not_Fiscal_Code__c = true;
        con.LastName = accounts[0].Name;
        con.Persona_Fisica__c = accounts[0].Id;

        contacts.add(con);

        insert contacts;
        return contacts;
    }


    public static List<Service_Request__c> createServiceRequests(List<Account> accounts, List<Contact> contacts) {
        List<Service_Request__c> serviceRequests = new List<Service_Request__c>();

        Service_Request__c sr = new Service_Request__c();
        sr.Account__c = accounts[0].Id;
        sr.Contact__c = contacts[0].Id;
        sr.CheckStatus__c = 'Aperta';
        sr.SR_Origin__c = 'URP';

        serviceRequests.add(sr);

        insert serviceRequests;
        return serviceRequests;
    }

    public static List<Synonymous__c> createSynonymous() {
        List<Synonymous__c> synonymous = new List<Synonymous__c>();

        Synonymous__c syn = new Synonymous__c();
        syn.Taxonomy_Value__c = 'AMBIENTE';
        syn.Synonym_value_1__c = 'NATURA';
        syn.Synonym_value_2__c = 'CIRCONDARIO';
        syn.Synonym_value_3__c = 'ALBERI';
        syn.Synonym_value_4__c = 'VERDE';
        syn.Synonym_value_5__c = 'CALAMITA\'';
        syn.Synonym_value_6__c = 'ANIMALI';
        syn.Synonym_value_7__c = null;
        syn.Synonym_value_8__c = null;
        syn.Synonym_value_9__c = null;
        syn.Synonym_value_10__c = null;
        syn.Synonim_Timestamp_Chiamata_CDC__c = null;

        Synonymous__c syn2 = new Synonymous__c();
        syn2.Taxonomy_Value__c = 'AREE VERDI E PARCHI PUBBLICI';
        syn2.Synonym_value_1__c = 'GIARDINO';
        syn2.Synonym_value_2__c = 'SPAZIO';
        syn2.Synonym_value_3__c = 'ALBERI';
        syn2.Synonym_value_4__c = 'VERDE';
        syn2.Synonym_value_5__c = 'CALAMITA\'';
        syn2.Synonym_value_6__c = 'ANIMALI';
        syn2.Synonym_value_7__c = null;
        syn2.Synonym_value_8__c = null;
        syn2.Synonym_value_9__c = null;
        syn2.Synonym_value_10__c = null;
        syn2.Synonim_Timestamp_Chiamata_CDC__c = null;

        synonymous.add(syn);
        synonymous.add(syn2);

        insert synonymous;
        return synonymous;
    }

    public static List<Taxonomy__c> createTaxonomys() {
        List<Taxonomy__c> taxonomys = new List<Taxonomy__c>();

        Taxonomy__c tax = new Taxonomy__c();
        tax.Tax_Type__c = 'E1';
        tax.Tax_Theme_Area__c = 'COMMERCIO E IMPRESA';
        tax.Tax_Specification__c = 'AAA ARTIGIANI APERTI AD AGOSTO';
        tax.Tax_Topic_Service__c = 'AAA ARTIGIANI APERTI AD AGOSTO';
        tax.Tax_Geolocalization__c = false;
        tax.Tax_CDC_Visible__c = true;
        tax.Tax_Timestamp_Chiamata_CDC__c = null;

        Taxonomy__c tax2 = new Taxonomy__c();
        tax2.Tax_Theme_Area__c = 'COMMERCIO E IMPRESA';
        tax2.Tax_Specification__c = 'AAA ARTIGIANI APERTI AD AGOSTO';
        tax2.Tax_Topic_Service__c = 'AAA ARTIGIANI APERTI AD AGOSTO';
        tax2.Tax_Type__c = 'CE1';
        tax2.Tax_Geolocalization__c = false;
        tax2.Tax_CDC_Visible__c = false;
        tax2.Tax_Timestamp_Chiamata_CDC__c = null;

        taxonomys.add(tax);
        taxonomys.add(tax2);

        insert taxonomys;
        return taxonomys;
    }

    public static Taxonomy__c creteTaxonomyByValues(String themArea, String TopicService, String Specification, Boolean TaxActive, Boolean CDCVisible, String Typeval) {
        return creteTaxonomyByValues(themArea, TopicService, Specification, TaxActive, CDCVisible, Typeval, false);
    }

    public static Taxonomy__c creteTaxonomyByValues(String themArea, String TopicService, String Specification, Boolean TaxActive, Boolean CDCVisible, String Typeval, Boolean isMajorRoads) {
        return creteTaxonomyByValues(themArea, TopicService, Specification, TaxActive, CDCVisible, Typeval, false, '1');
    }

    public static Taxonomy__c creteTaxonomyByValues(String themArea, String TopicService, String Specification, Boolean TaxActive, Boolean CDCVisible, String Typeval, Boolean isMajorRoads, String GeoMunicipality) {
        return creteTaxonomyByValues(themArea, TopicService, Specification, TaxActive, CDCVisible, Typeval, false, '1', null);
    }

    public static Taxonomy__c creteTaxonomyByValues(String themArea, String TopicService, String Specification, Boolean TaxActive, Boolean CDCVisible, String Typeval, Boolean isMajorRoads, String GeoMunicipality, String TaxQueue) {
        Taxonomy__c tmpTaxonomy = new Taxonomy__c();
        tmpTaxonomy.Tax_Theme_Area__c = themArea;
        tmpTaxonomy.Tax_Topic_Service__c = TopicService;
        tmpTaxonomy.Tax_Specification__c = Specification;
        tmpTaxonomy.Tax_Active__c = ( TaxActive ? TaxActive : true);
        tmpTaxonomy.Tax_CDC_Visible__c = ( CDCVisible ? CDCVisible : false );
        tmpTaxonomy.Tax_Type__c = ( Typeval != null ? Typeval : 'A1'); //Segnalazione
        tmpTaxonomy.MajorRoads__c = isMajorRoads;
        tmpTaxonomy.Geo_Municipality__c = GeoMunicipality;
        tmpTaxonomy.Tax_Queue__c = TaxQueue;
        if (String.isNotBlank(GeoMunicipality)) tmpTaxonomy.Tax_Geolocalization__c = true;
        insert tmpTaxonomy;
        return tmpTaxonomy;
    }

    public static MajorRoads__c createSingleMajorRoads(String AddressVal, Boolean isPartial) {
        MajorRoads__c singleMajorRoads = new MajorRoads__c();
        singleMajorRoads.PartialViability__c = isPartial;
        singleMajorRoads.Name = AddressVal;
        insert singleMajorRoads;
        return singleMajorRoads;
    }

    public static List<GoogleMaps__c> createGoogleMaps() {
        List<GoogleMaps__c> gMaps = new List<GoogleMaps__c>();

        GoogleMaps__c gMap = new GoogleMaps__c();

        gMaps.add(gMap);

        insert gMaps;
        return gMaps;
    }

    public static List<Communities__c> createCommunities() {
        Communities__c comunity = new Communities__c();
        Communities__c comunityExternal = new Communities__c();
        List<Communities__c> comunities = new List<Communities__c>();

        comunity.Name = 'Siena';
        comunity.province_long__c = 'Siena';
        comunity.province_short__c = 'SI';
        comunity.Code__c = 'I726';

        comunityExternal.Name = 'INDIA';
        comunityExternal.province_long__c = 'Estero';
        comunityExternal.province_short__c = 'EE';
        comunityExternal.Code__c = 'Z222';

        comunities.add(comunity);
        comunities.add(comunityExternal);
        insert comunities;

        return comunities;
    }

    public static List<Case> createCases() {
        List<Case> listCases = new List<Case>();

        Case caseOne = new Case();
        caseOne.Type = 'URP';
        caseOne.Sent_to_External__c = 'Not Sync';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via Test, 43,Roma';
        caseOne.Number_Address__c = 12;
        caseOne.Letter_Address__c = 'test';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.Concession_Municipality__c = 'Roma';
        caseOne.Case_Specification__c = 'Test';
        caseOne.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));

        Case caseTwo = new Case();
        caseTwo.Type = 'URP';
        caseTwo.Sent_to_External__c = 'Not Sync';
        caseTwo.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'ZTL' LIMIT 1].Id;
        caseTwo.Case_Theme_Area__c = 'test2';
        caseTwo.Street_Address__c = 'Via Test2, 43,Roma';
        caseTwo.Number_Address__c = 12;
        caseTwo.Letter_Address__c = 'test2';
        caseTwo.License_plate__c = '12346';
        caseTwo.Concession_Number__c = '1235';
        caseTwo.Concession_Municipality__c = 'Siena';
        caseTwo.Case_Specification__c = 'Test2';
        caseTwo.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseTwo.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));

        listCases.add(caseOne);
        listCases.add(caseTwo);

        insert listCases;
        return listCases;
    }

    public static List<Case> createSingleCasesWithoutCities() {
        List<Case> listCases = new List<Case>();

        Case caseOne = new Case();
        caseOne.Type = 'AMA LineaVerde';
        caseOne.Origin = 'CDC';
        caseOne.Sent_to_External__c = 'Not Sync';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via di S. Agostino, 00186 Roma RM, Italy';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.Case_Specification__c = 'Test';
        caseOne.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));

        listCases.add(caseOne);

        insert listCases;
        return listCases;
    }

    public static List<Case> createCasesBrogliaccioPull() {
        List<Account> accounts = createAccounts();

        List<Case> listCases = new List<Case>();

        Case caseOne = new Case();
        caseOne.Type = 'AMA LineaVerde';
        caseOne.Origin = 'CDC';
        caseOne.Sent_to_External__c = 'Sync';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via di S. Agostino, 00186 Roma RM, Italy';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.Case_Specification__c = 'Test';
        caseOne.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.To_be_sent_Brogliaccio__c = true;
        caseOne.ExternalSystemId_Brogliaccio__c = '1234';
        caseOne.Status = 'Closed';
        caseOne.Sub_Status__c = 'In carico a Ente Esterno';
        caseOne.AccountId = accounts[0].Id;
        caseOne.Closed_Reason__c = 'In carico a Ente Esterno';

        listCases.add(caseOne);

        insert listCases;
        return listCases;
    }

    public static List<Case> createCasesWithoutCities() {
        List<Case> listCases = new List<Case>();

        Case caseOne = new Case();
        caseOne.Type = 'AMA LineaVerde';
        caseOne.Origin = 'CDC';
        caseOne.Sent_to_External__c = 'To Be Sync';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via di S. Agostino, 00186 Roma RM, Italy';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.Case_Specification__c = 'Test';
        caseOne.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseOne.To_be_sent_Brogliaccio__c = true;
        caseOne.ProtocolCFUser__c = '1234';
        caseOne.DateTimeProtocol__c = System.today();

        Case caseTwo = new Case();
        caseTwo.Type = 'AMA LineaVerde';
        caseTwo.Origin = 'CDC';
        caseTwo.Sent_to_External__c = 'Not Sync';
        caseTwo.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'ZTL' LIMIT 1].Id;
        caseTwo.Case_Theme_Area__c = 'test2';
        caseTwo.Street_Address__c = 'Piazza Dei Santi Apostoli, 80a/81, 00187 Roma RM, Italy';
        caseTwo.License_plate__c = '12346';
        caseTwo.Concession_Number__c = '1235';
        caseTwo.Case_Specification__c = 'Test2';
        caseTwo.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseTwo.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseTwo.ProtocolCFUser__c = '1235';

        Case caseThree = new Case();
        caseThree.Type = 'AMA LineaVerde';
        caseThree.Origin = 'CDC';
        caseThree.Sent_to_External__c = 'Not Sync';
        caseThree.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseThree.Case_Theme_Area__c = 'test';
        caseThree.Street_Address__c = 'Via Agostino, 00186 Roma RM, Italy';
        caseThree.License_plate__c = '12345';
        caseThree.Concession_Number__c = '1234';
        caseThree.Case_Specification__c = 'Test';
        caseThree.Start_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2013, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseThree.Finish_Day_Access__c = Datetime.newInstanceGmt(Date.newInstance(2015, 11, 12), Time.newInstance(3, 3, 3, 0));
        caseThree.ProtocolCFUser__c = '1236';

        listCases.add(caseOne);
        listCases.add(caseTwo);
        listCases.add(caseThree);

        insert listCases;
        return listCases;
    }

    public static List<City__c> createCities() {
        List<City__c> cities = new List<City__c>();

        City__c city = new City__c();
        city.Name = 'Roma';
        city.Numeric_City_Code__c = '12345';
        city.Alphanumeric_City_Code__c = '12345';

        City__c city2 = new City__c();
        city2.Name = 'Siena';
        city2.Numeric_City_Code__c = '12346';
        city2.Alphanumeric_City_Code__c = '12346';

        cities.add(city);
        cities.add(city2);

        insert cities;
        return cities;
    }

    public static List<UserRole> createParentUserRole() {
        List<UserRole> roleParents = new List<UserRole>();

        UserRole roleParent = new UserRole();
        roleParent.Name = 'Parent';
        roleParents.add(roleParent);

        insert roleParents;
        return roleParents;
    }

    public static List<UserRole> createUserRole(String parentRoleId) {
        List<UserRole> roles = new List<UserRole>();

        UserRole role = new UserRole();
        role.Name = 'Child';
        role.ParentRoleId = parentRoleId;

        roles.add(role);

        insert roles;
        return roles;
    }

    public static List<GroupMember> createGroupMembers(List<Group> groups) {
        List<GroupMember> groupMembers = new List<GroupMember>();

        List<Group> g = createParentGroups();

        GroupMember gm = new GroupMember();
        gm.UserOrGroupId = groups[0].Id;
        gm.GroupId = g[0].Id;

        groupMembers.add(gm);

        insert groupMembers;
        return  groupMembers;
    }

    public static List<ContentVersion> createContentVersions(List<Case> cases) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        Integer looper = 1;
        for(Case c : cases) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'ABC'+looper;
            cv.PathOnClient ='test.txt'+looper;
            Blob b=Blob.valueOf('Unit Test Attachment Body'+looper);
            cv.VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body'+looper);
            cv.CaseId__c = c.Id;
            looper++;
            contentVersions.add(cv);
        }

        insert contentVersions;
        return [SELECT VersionData, Title, PathOnClient, CaseId__c, ContentDocumentId, FileExtension FROM ContentVersion WHERE Id IN: contentVersions];
    }

    public static List<LogicalDeleteBatch_Setting__c> createLogicalDeleteBatchSettings() {
        List<LogicalDeleteBatch_Setting__c> batchCustomSettingList = new List<LogicalDeleteBatch_Setting__c>();

        LogicalDeleteBatch_Setting__c structureLogicalDeleteBatch = new LogicalDeleteBatch_Setting__c();
        structureLogicalDeleteBatch.Name = 'StructureLogicalDeleteBatch';
        structureLogicalDeleteBatch.subject__c = 'Riepilogo Strutture che verranno eliminati tra una settimana: ';
        structureLogicalDeleteBatch.bodyHtml__c = 'I seguenti ruoli verranno eliminati tra : <br/><br/>';
        structureLogicalDeleteBatch.bodyHtmlAlternative__c = 'Nessuna struttura verrà eliminato fra una settimana <br /> <br />';
        structureLogicalDeleteBatch.Batch_Size__c = 200;
        structureLogicalDeleteBatch.minutes__c = -10;
        structureLogicalDeleteBatch.hours__c = -20;
        structureLogicalDeleteBatch.schedule_minutes__c = 30;

        LogicalDeleteBatch_Setting__c employeeLogicalDeleteBatch = new LogicalDeleteBatch_Setting__c();
        employeeLogicalDeleteBatch.Name = 'EmployeeLogicalDeleteBatch';
        employeeLogicalDeleteBatch.subject__c = 'Riepilogo Dipendenti che verranno eliminati tra una settimana: ';
        employeeLogicalDeleteBatch.bodyHtml__c = 'I seguenti dipendenti sono stati eliminati tra : <br/><br/>';
        employeeLogicalDeleteBatch.bodyHtmlAlternative__c = 'Nessun dipendente verrà eliminato fra una settimana <br /> <br />';
        employeeLogicalDeleteBatch.Batch_Size__c = 200;
        employeeLogicalDeleteBatch.minutes__c = -10;
        employeeLogicalDeleteBatch.hours__c = -20;
        employeeLogicalDeleteBatch.schedule_minutes__c = 30;

        LogicalDeleteBatch_Setting__c roleLogicalDeleteBatch = new LogicalDeleteBatch_Setting__c();
        roleLogicalDeleteBatch.Name = 'RoleLogicalDeleteBatch';
        roleLogicalDeleteBatch.subject__c = 'Riepilogo Ruoli che verranno eliminati tra una settimana: ';
        roleLogicalDeleteBatch.bodyHtml__c = 'I seguenti ruoli sono stati eliminati tra : <br/><br/>';
        roleLogicalDeleteBatch.bodyHtmlAlternative__c = 'Nessun ruolo verrà eliminato fra una settimana <br /> <br />';
        roleLogicalDeleteBatch.Batch_Size__c = 200;
        roleLogicalDeleteBatch.minutes__c = -10;
        roleLogicalDeleteBatch.hours__c = -20;
        roleLogicalDeleteBatch.schedule_minutes__c = 30;


        batchCustomSettingList.add(structureLogicalDeleteBatch);
        batchCustomSettingList.add(employeeLogicalDeleteBatch);
        batchCustomSettingList.add(roleLogicalDeleteBatch);

        insert batchCustomSettingList;
        return batchCustomSettingList;
    }

    public static List<FisicalDeleteBatch_Setting__c> createFisicalDeleteBatchSettings() {
        List<FisicalDeleteBatch_Setting__c> batchCustomSettingList = new List<FisicalDeleteBatch_Setting__c>();
        FisicalDeleteBatch_Setting__c structureFisicalDeleteBatch = new FisicalDeleteBatch_Setting__c();
        structureFisicalDeleteBatch.Name = 'StructureFisicalDeleteBatch';
        structureFisicalDeleteBatch.subject__c = 'Riepilogo Strutture che sono state eliminate: ';
        structureFisicalDeleteBatch.bodyHtml__c = 'Le seguenti strutture sono state eliminate : <br/><br/>';
        structureFisicalDeleteBatch.bodyHtmlAlternative__c = 'Nessuna struttura è stata eliminata <br /> <br />';
        structureFisicalDeleteBatch.Batch_Size__c = 200;
        structureFisicalDeleteBatch.days__c = -5;
        FisicalDeleteBatch_Setting__c employeeFisicalDeleteBatch = new FisicalDeleteBatch_Setting__c();
        employeeFisicalDeleteBatch.Name = 'EmployeeFisicalDeleteBatch';
        employeeFisicalDeleteBatch.subject__c = 'Riepilogo Dipendenti che sono stati eliminati: ';
        employeeFisicalDeleteBatch.bodyHtml__c = 'I seguenti dipendenti sono stati eliminati : <br/><br/>';
        employeeFisicalDeleteBatch.bodyHtmlAlternative__c = 'Nessun dipendente è stato eliminato <br /> <br />';
        employeeFisicalDeleteBatch.Batch_Size__c = 200;
        employeeFisicalDeleteBatch.days__c = -5;
        FisicalDeleteBatch_Setting__c roleFisicalDeleteBatch = new FisicalDeleteBatch_Setting__c();
        roleFisicalDeleteBatch.Name = 'RoleFisicalDeleteBatch';
        roleFisicalDeleteBatch.subject__c = 'Riepilogo Ruoli che sono stati eliminati: ';
        roleFisicalDeleteBatch.bodyHtml__c = 'I seguenti ruoli sono stati eliminati : <br/><br/>';
        roleFisicalDeleteBatch.bodyHtmlAlternative__c = 'Nessun ruolo è stato eliminato <br /> <br />';
        roleFisicalDeleteBatch.Batch_Size__c = 200;
        roleFisicalDeleteBatch.days__c = -5;
        FisicalDeleteBatch_Setting__c batchDeleteAccountDraft = new FisicalDeleteBatch_Setting__c();
        batchDeleteAccountDraft.Name = 'BatchDeleteAccountDraft';
        batchDeleteAccountDraft.Batch_Size__c = 200;
        FisicalDeleteBatch_Setting__c batchInCreationCaseDelete = new FisicalDeleteBatch_Setting__c();
        batchInCreationCaseDelete.Name = 'BatchInCreationCaseDelete';
        batchInCreationCaseDelete.Batch_Size__c = 200;
        batchInCreationCaseDelete.days__c = 0;
        batchCustomSettingList.add(batchInCreationCaseDelete);
        batchCustomSettingList.add(structureFisicalDeleteBatch);
        batchCustomSettingList.add(employeeFisicalDeleteBatch);
        batchCustomSettingList.add(roleFisicalDeleteBatch);
        batchCustomSettingList.add(batchDeleteAccountDraft);
        insert batchCustomSettingList;
        return batchCustomSettingList;
    }

    public static List<AMABatch_Setting__c> createAMABatchSettings() {
        List<AMABatch_Setting__c> amaBatchList = new List<AMABatch_Setting__c>();

        AMABatch_Setting__c amaBatch = new AMABatch_Setting__c();
        amaBatch.Name = 'SendToAMABatch';
        amaBatch.group_name__c = 'AMA_LINEA_VERDE';
        amaBatch.Sent_to_External__c = 'Sync';
        amaBatch.Lowest_Time_Hours__c = 1;
        amaBatch.Upper_Time_Minutes__c = -1;
        amaBatch.Batch_Size__c = 50;
        amaBatch.Status__c = 'Working';
        amaBatch.Sub_Status__c = 'In carico a Ente Esterno';

        amaBatchList.add(amaBatch);

        insert amaBatchList;
        return amaBatchList;
    }

    public static List<RSMBatch_Setting__c> createRSMBatchSettings() {
        List<RSMBatch_Setting__c> rsmBatchList = new List<RSMBatch_Setting__c>();

        RSMBatch_Setting__c rsmBatch = new RSMBatch_Setting__c();
        rsmBatch.Name = 'SendToRSMBatch';
        rsmBatch.group_name__c = 'ROMA_MOBILITA_ZTL_DISABILI';
        rsmBatch.Sent_to_External__c = 'Sync';
        rsmBatch.Batch_Size__c = 50;
        rsmBatch.Closed_Reason__c = 'In carico a ente esterno';
        rsmBatch.Lowest_Time_Hours__c = 1;
        rsmBatch.Status__c = 'Closed';
        rsmBatch.Sub_Status__c = 'Chiuso';
        rsmBatch.Upper_Time_Minutes__c = -1;

        rsmBatchList.add(rsmBatch);

        insert rsmBatchList;
        return rsmBatchList;
    }

    public static List<Case> createCasesWithAccountContact(String accId, String conId) {
        List<Case> listCases = new List<Case>();

        Case caseOne = new Case();
        caseOne.Type = 'URP';
        caseOne.Sent_to_External__c = 'Not Sync';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via Test, 43,Roma';
        caseOne.Number_Address__c = 12;
        caseOne.Letter_Address__c = 'test';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.AccountId = accId;
        caseOne.ContactId = conId;
        caseOne.Case_Action__c = 'Rigetto';

        Case caseTwo = new Case();
        caseTwo.Type = 'URP';
        caseTwo.Sent_to_External__c = 'Not Sync';
        caseTwo.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'ZTL' LIMIT 1].Id;
        caseTwo.Case_Theme_Area__c = 'test2';
        caseTwo.Street_Address__c = 'Via Test2, 43,Roma';
        caseTwo.Number_Address__c = 12;
        caseTwo.Letter_Address__c = 'test2';
        caseTwo.License_plate__c = '12346';
        caseTwo.Concession_Number__c = '1235';
        caseTwo.AccountId = accId;
        caseTwo.ContactId = conId;
        caseTwo.Case_Action__c = 'Rigetto';

        listCases.add(caseOne);
        listCases.add(caseTwo);

        insert listCases;
        return listCases;
    }

    public static List<Case> createCaseWithOwnerGroup() {
        List<Group> groups = createGroups();
        List<Case> cases = new List<Case>();
        Case caseOne = new Case();

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        dmo.assignmentRuleHeader.assignmentRuleId = null;

        caseOne.setOptions(dmo);
        caseOne.Type = 'AMA LineaVerde';
        caseOne.Origin = 'CDC';
        caseOne.Sent_to_External__c = 'To Be Sync';
        caseOne.Case_Theme_Area__c = 'test';
        caseOne.Street_Address__c = 'Via di S. Agostino, 00186 Roma RM, Italy';
        caseOne.License_plate__c = '12345';
        caseOne.Concession_Number__c = '1234';
        caseOne.Case_Specification__c = 'Test';
        //caseOne.OwnerId = groups[1].Id;
        caseOne.call_mailup__c = true;
        caseOne.Subject_Email__c = 'subject';
        caseOne.EmailTemplate__c = 'body';

        cases.add(caseOne);

        insert cases;
        return cases;
    }

    public static List<BatchArticlesManagement_Setting__c> createBatchArticlesSettingLists() {
        List<BatchArticlesManagement_Setting__c> batchArticlesManagementSettings = new List<BatchArticlesManagement_Setting__c>();

        BatchArticlesManagement_Setting__c batchArticlesManagementSetting = new BatchArticlesManagement_Setting__c();
        batchArticlesManagementSetting.Name = 'BatchArticlesManagement';
        batchArticlesManagementSetting.Batch_Size__c = 200;
        batchArticlesManagementSetting.hours__c = 24;

        batchArticlesManagementSettings.add(batchArticlesManagementSetting);

        insert batchArticlesManagementSettings;
        return batchArticlesManagementSettings;
    }

    public static List<OrgManagement__c> createOrgManagementSettings() {
        List<OrgManagement__c> orgs = new List<OrgManagement__c>();

        OrgManagement__c org = new OrgManagement__c();
        org.Id_List_MailUp__c = '1';
        org.Sla__c = 10;
        org.Time_Attachment_GED__c = '30';
        org.Limit_Attachment_GED__c = '40';
        org.ms_to_Secs__c = 1000;
        org.Bytes_to_MB__c = 1024;

        org.Brogliaccio_Queue__c = 'GRUPPO BROGLIACCIO – POLIZIA LOCALE';
        org.Brogliaccio_Queue_API__c = 'GRUPPO_BROGLIACCIO_POLIZIA_LOCALE';
        org.ZTL_Queue_API__c = 'ROMA_MOBILITA_ZTL_DISABILI';
        org.ZTL_Queue_Label__c = 'ROMA MOBILITA – ZTL DISABILI';
        org.AMA_Queue_API__c = 'AMA_LINEA_VERDE';
        org.AMA_Queue_Label__c = 'AMA LINEA VERDE';

        orgs.add(org);

        insert orgs;
        return orgs;
    }

    public static Case createInCreationCase(){
        Case newCase = new Case();
        newCase.Status = 'In Creazione';
        newCase.Type = 'ZTL';
        newCase.Origin = 'CDC';
        insert newCase;
        return newCase;
    }

    // public static List<ServiceAppointment> createServiceAppointments() {
    //     List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();

    //     List<Account> accounts = createBusinessAccounts();
    //     List<Contact> contacts = createBusinessContacts(accounts);

    //     ServiceAppointment saOne = new ServiceAppointment();
    //     saOne.ContactId = contacts[0].Id;
    //     saOne.SchedStartTime = Datetime.newInstance(2021, 10, 12, 16, 00, 00);
    //     saOne.SchedEndTime = Datetime.newInstance(2021, 10, 12, 16, 10, 00);
    //     saOne.AdditionalInformation = 'Area Societaria';
    //     saOne.ParentRecordId = accounts[0].Id;
    //     saOne.Sms_type__c = 'Nuovo';
    //     saOne.SMS_Template_MailUp__c = 'body';
    //     saOne.SMS_Subject__c = 'subject';
    //     saOne.Phone = 'xxxxx';

    //     serviceAppointments.add(saOne);

    //     insert serviceAppointments;
    //     return serviceAppointments;
    // }

    public static List<MailUpBatch_Settings__c> createMailUpBatchSettings() {
        List<MailUpBatch_Settings__c> mailUpBatchSettings = new List<MailUpBatch_Settings__c>();

        MailUpBatch_Settings__c mailUpBatchSetting = new MailUpBatch_Settings__c();
        mailUpBatchSetting.Batch_Size__c = 50;
        mailUpBatchSetting.Name = 'BatchMailUp';
        mailUpBatchSetting.Status__c = 'Working';
        mailUpBatchSetting.Sub_Status__c = 'In carico a Ente Esterno';
        mailUpBatchSetting.Lowest_Time_Hours__c = 0;

        mailUpBatchSettings.add(mailUpBatchSetting);

        insert mailUpBatchSettings;
        return mailUpBatchSettings;
    }

    public static List<MailUpSMSInvocable.FlowInput> createMailUpSMSFlowInputs() {
        List<MailUpSMSInvocable.FlowInput> flowInputs = new List<MailUpSMSInvocable.FlowInput>();
        MailUpSMSInvocable.FlowInput flow = new MailUpSMSInvocable.FlowInput();
        flow.serviceAppointmentId = '111111111';
        flow.idList = '1';
        flow.type = 'Nuovo';
        flow.phoneNumber = '12345';
        flow.smsSubject = 'Subject';
        flow.smsBody = 'Body';

        flowInputs.add(flow);

        return flowInputs;
    }

    public static List<MailUpMailInvocable.FlowInput> createMailUpMailFlowInputs() {
        List<MailUpMailInvocable.FlowInput> flowInputs = new List<MailUpMailInvocable.FlowInput>();
        MailUpMailInvocable.FlowInput flow = new MailUpMailInvocable.FlowInput();
        flow.theCase = createCasesWithoutCities()[0];
        flow.listId = '1';
        flow.groupId = '12';
        flow.templateSubject = 'Subject';
        flow.templateBody = 'Body';
        flow.isForRecipient = false;

        flowInputs.add(flow);

        return flowInputs;
    }

    public static List<MailUpGroup__c> createMailUpGroups() {
        List<MailUpGroup__c> mailUpGroups = new List<MailUpGroup__c>();

        MailUpGroup__c mailUpGroup = new MailUpGroup__c();
        mailUpGroup.Name = 'TestGroupMail';
        mailUpGroup.Id_List__c = '1';
        mailUpGroup.DeveloperNameQueue__c = 'TestGroupMail';

        mailUpGroups.add(mailUpGroup);

        insert mailUpGroups;
        return mailUpGroups;
    }

    public static List<MailUpMailWrapper> createMailUpMailWrappers() {
        List<MailUpMailWrapper> mailUpMailWrappers = new List<MailUpMailWrapper>();
        List<Case> cases = createCasesWithoutCities();

        MailUpMailWrapper mailUpMailWrapper = new MailUpMailWrapper();
        mailUpMailWrapper.singleCase = cases[0];
        mailUpMailWrapper.caseId = cases[0].Id;
        mailUpMailWrapper.listId = '1';
        mailUpMailWrapper.groupId = '12';
        mailUpMailWrapper.templateSubject = 'some subject';
        mailUpMailWrapper.templateBody = 'some body';
        mailUpMailWrapper.queueName = 'myQueue';
        mailUpMailWrapper.queueEmail = 'myEmail';
        mailUpMailWrapper.amaRiciclaCasaEmail = 'myEmailAma';
        mailUpMailWrapper.pecValue = true;
        mailUpMailWrapper.amaRiciclaCasaQueue = 'myQueue';
        mailUpMailWrapper.emailExternalSystem = 'email@external.com';
        mailUpMailWrapper.pecExternalSystem = 'pec@external.com';
        mailUpMailWrapper.isForRecipient = false;

        mailUpMailWrappers.add(mailUpMailWrapper);

        return mailUpMailWrappers;
    }

    public static List<SMSWrapper> createSMSWrapper() {
        List<SMSWrapper> smsWrappers = new List<SMSWrapper>();
        List<Case> cases = createCasesWithoutCities();
        // List<ServiceAppointment> serviceAppointments = createServiceAppointments();

        SMSWrapper smsWrapper = new SMSWrapper();
        smsWrapper.caseId = cases[0].Id;
        smsWrapper.idList = '1';
        // smsWrapper.serviceAppointmentId = serviceAppointments[0].Id;
        smsWrapper.smsType = 'Nuovo';
        smsWrapper.phoneNumber = 'some body';
        smsWrapper.contentLength = 'myQueue';
        smsWrapper.smsSubject = 'myEmail';
        smsWrapper.smsBody = 'myEmailAma';

        smsWrappers.add(smsWrapper);

        return smsWrappers;
    }

    public static BrogliaccioCaseListWrapperNew createBrogliaccioCaseListWrapperNew(Boolean isFromComponent, List<Case> myCases) {
        List<Case> cases = myCases;

        BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapperNew = new BrogliaccioCaseListWrapperNew(isFromComponent, cases);

        return brogliaccioCaseListWrapperNew;
    }

    public static List<BrogliaccioBatch_Setting__c> createBrogliaccioBatchSettings() {
        List<BrogliaccioBatch_Setting__c> brogliaccioBatchList = new List<BrogliaccioBatch_Setting__c>();

        BrogliaccioBatch_Setting__c brogliaccioBatch = new BrogliaccioBatch_Setting__c();
        brogliaccioBatch.Name = 'SendToBrogliaccioBatch';
        brogliaccioBatch.Batch_Size__c = 200;
        brogliaccioBatch.Upper_Time_Minutes__c = -2;
        brogliaccioBatch.Lowest_Time_Hours__c = 12;
        brogliaccioBatch.Group_Name__c = 'GRUPPO BROGLIACCIO – POLIZIA LOCALE';
        brogliaccioBatch.Group_Dev_Name__c = 'GRUPPO_BROGLIACCIO_POLIZIA_LOCALE';
        brogliaccioBatch.Sub_Status__c = 'In carico a ente esterno';
        brogliaccioBatch.Closed_Reason__c = 'In carico a ente esterno';

        brogliaccioBatchList.add(brogliaccioBatch);

        insert brogliaccioBatchList;
        return brogliaccioBatchList;
    }

    public static List<Activity_Case_Error__c> createActivityCaseErrors() {
        // List<ServiceAppointment> serviceAppointments = createServiceAppointments();
        List<Activity_Case_Error__c> activityCaseErrors = new List<Activity_Case_Error__c>();

        Activity_Case_Error__c ace = new Activity_Case_Error__c();
        ace.Message_Type__c = 'Email';
        ace.Status__c = 'Not Sent';
        ace.Last_Batch_Date_Time__c = null;

        Activity_Case_Error__c ace2 = new Activity_Case_Error__c();
        ace2.Message_Type__c = 'Email';
        ace2.Status__c = 'Not Sent';
        ace2.Send_to_Recipient__c = true;
        ace2.Last_Batch_Date_Time__c = null;

        Activity_Case_Error__c aceSms = new Activity_Case_Error__c();
        aceSms.Message_Type__c = 'SMS';
        aceSms.Status__c = 'Not Sent';
        aceSms.SMS_Template__c = 'Body';
        aceSms.Phone_Number__c = '123456789';
        aceSms.Last_Batch_Date_Time__c = null;

        Activity_Case_Error__c aceSms2 = new Activity_Case_Error__c();
        aceSms2.Message_Type__c = 'SMS';
        aceSms2.Status__c = 'Not Sent';
        aceSms2.SMS_Template__c = 'Body';
        aceSms2.Phone_Number__c = '123456789';
        // aceSms2.Service_Appointment__c = serviceAppointments[0].Id;
        aceSms2.Last_Batch_Date_Time__c = null;

        activityCaseErrors.add(ace);
        activityCaseErrors.add(ace2);
        activityCaseErrors.add(aceSms);
        activityCaseErrors.add(aceSms2);

        insert activityCaseErrors;
        return activityCaseErrors;
    }

    public static List<SMS__c> createSms() {
        List<SMS__c> smsList = new List<SMS__c>();

        SMS__c sms = new SMS__c();

        smsList.add(sms);

        insert smsList;
        return smsList;
    }

    public static List<EmailMessage> createEmailMessages() {
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        EmailMessage emailMessage = new EmailMessage();
        emailMessage.Subject = 'Hello';
        emailMessage.FromName = 'Tester';

        emailMessages.add(emailMessage);

        insert emailMessages;
        return emailMessages;
    }

    public static List<Favorite__c> createFavorites() {
        List<Favorite__c> favorites = new List<Favorite__c>();

        Favorite__c favorite = new Favorite__c();
        favorite.IsActive__c = false;
        favorite.Type__c = 'Municipio';

        Favorite__c favorite2 = new Favorite__c();
        favorite2.IsActive__c = false;
        favorite2.Type__c = 'Aree Tematiche';

        favorites.add(favorite);
        favorites.add(favorite2);

        insert favorites;
        return favorites;
    }

    public static List<FavoriteAssociation__c> createFavoriteAssociations(List<Favorite__c> favorites, List<Contact> contacts) {
        List<FavoriteAssociation__c> favoriteAssociations = new List<FavoriteAssociation__c>();

        for(Favorite__c fav : favorites) {
            FavoriteAssociation__c favoriteAssociation = new FavoriteAssociation__c();
            favoriteAssociation.FavoriteId__c = fav.Id;
            favoriteAssociation.ContactId__c = contacts[0].Id;
            favoriteAssociation.IsActive__c = true;

            favoriteAssociations.add(favoriteAssociation);
        }

        System.debug('favoriteAssociations -> '+ favoriteAssociations);
        insert favoriteAssociations;
        return favoriteAssociations;
    }

    public static BatchDeleteFavoritesAndAssociations__c createBatchDeleteFavoritesAndAssociations() {
        BatchDeleteFavoritesAndAssociations__c batchDeleteFavoritesAndAssociations = new BatchDeleteFavoritesAndAssociations__c();

        batchDeleteFavoritesAndAssociations.Batch_Size__c = 200;
        batchDeleteFavoritesAndAssociations.Name = 'BatchDeleteFavoritesAndAssociations';

        insert batchDeleteFavoritesAndAssociations;
        return batchDeleteFavoritesAndAssociations;
    }

    public static List<Role_Orchestrator__mdt> createRoleOrchestrators() {
        List<Role_Orchestrator__mdt> roleOrchestrators = new List<Role_Orchestrator__mdt>();

        Role_Orchestrator__mdt roleOrchestrator1 = new Role_Orchestrator__mdt(Label='URP', DeveloperName='URP');
        Role_Orchestrator__mdt roleOrchestrator2 = new Role_Orchestrator__mdt(Label='Operatore CC', DeveloperName='Operatore_CC');
        Role_Orchestrator__mdt roleOrchestrator3 = new Role_Orchestrator__mdt(Label='Istruttore', DeveloperName='Istruttore');

        roleOrchestrators.add(roleOrchestrator1);
        roleOrchestrators.add(roleOrchestrator2);
        roleOrchestrators.add(roleOrchestrator3);

        return roleOrchestrators;
    }

    public static List<Holidays__c> createHolidays() {
        List<Holidays__c> allHolidays = new List<Holidays__c>();
        Holidays__c newHolidayNORecursive = new Holidays__c();
        Date today = Date.today().addDays(30);
        newHolidayNORecursive.HolidayDate__c = Date.newInstance(today.year(), today.month(), today.day());
        newHolidayNORecursive.Name = 'Pasqua';
        newHolidayNORecursive.NoRecursive__c = true;
        newHolidayNORecursive.RecursiveAnnual__c = false;
        newHolidayNORecursive.RecursiveWeekly__c = false;
        newHolidayNORecursive.isActive__c = true;
        allHolidays.add(newHolidayNORecursive);

        Holidays__c newHolidayRecursive = new Holidays__c();
        newHolidayRecursive.HolidayDate__c = Date.newInstance(2022, 1, 1);
        newHolidayRecursive.Name = 'Capodanno';
        newHolidayRecursive.NoRecursive__c = false;
        newHolidayRecursive.RecursiveAnnual__c = true;
        newHolidayRecursive.RecursiveWeekly__c = false;
        newHolidayRecursive.isActive__c = true;
        allHolidays.add(newHolidayRecursive);

        Holidays__c newHolidayWeek = new Holidays__c();
        newHolidayWeek.WeekDay__c = 'Domenica';
        newHolidayWeek.Name = 'Domenica';
        newHolidayWeek.NoRecursive__c = false;
        newHolidayWeek.RecursiveAnnual__c = false;
        newHolidayWeek.RecursiveWeekly__c = true;
        newHolidayWeek.isActive__c = true;
        allHolidays.add(newHolidayWeek);

        insert allHolidays;
        return allHolidays;
    }

    public static List<BrogliaccioBatch_Pull_Setting__c> createBatchPullSettings() {
        BrogliaccioBatch_Pull_Setting__c setting = new BrogliaccioBatch_Pull_Setting__c();
        BrogliaccioBatch_Pull_Setting__c settingMinor = new BrogliaccioBatch_Pull_Setting__c();
        BrogliaccioBatch_Pull_Setting__c settingTime = new BrogliaccioBatch_Pull_Setting__c();
        List<BrogliaccioBatch_Pull_Setting__c> settings = new List<BrogliaccioBatch_Pull_Setting__c>();


        setting.Name = '6';
        setting.Status__c = 'Working';
        setting.Query_Status__c = 'Closed';
        setting.Query_Sub_Status__c = 'In carico a Ente Esterno';
        setting.Sub_Status__c = 'Rigettato';
        setting.Motivo_chiusura__c = 'blank';
        setting.Rejection__c = true;
        setting.Skip_Validation__c = true;
        setting.Brogliaccio_Reject__c = true;
        setting.Current_Queue__c = 'COMANDO POLIZIA LOCALE';
        setting.Current_Queue_Dev_Name__c = 'POLIZIA_LOCALE_CENTRALE_OPERATIVA';
        setting.Prior_Queue__c = 'GRUPPO BROGLIACCIO – POLIZIA LOCALE';
        setting.Case_Action__c = 'Rigetto';
        setting.Case_Action_Comment__c = 'Rigetto Brogliaccio';

        settingMinor.Name = '5';
        settingMinor.Status__c = 'Close';
        settingMinor.Query_Status__c = 'Closed';
        settingMinor.Query_Sub_Status__c = 'In carico a Ente Esterno';
        settingMinor.Sub_Status__c = 'Chiuso';
        settingMinor.Skip_Validation__c = true;

        settingTime.Name = 'BrogliaccioPullBatch';
        settingTime.Upper_Time_Minutes__c = 1;
        settingTime.Lowest_Time_Hours__c = 8760;

        settings.add(setting);
        settings.add(settingMinor);
        settings.add(settingTime);

        insert settings;
        return settings;
    }

    public static List<Citizen_Wallets_Table__c> createCitizenWalletsTables() {
        List<Citizen_Wallets_Table__c> settings = new List<Citizen_Wallets_Table__c>();

        Citizen_Wallets_Table__c setting = new Citizen_Wallets_Table__c();
        setting.Name = 'Citizen Wallets';
        setting.No_of_Transactions_per_Page__c = 5;
        setting.No_of_Wallets_per_Page__c = 1;

        settings.add(setting);

        insert settings;
        return settings;
    }

    public static List<Favorite__c> createFavorite(Integer numberItems) {
        List<Favorite__c> favoriteList = new List<Favorite__c>();
        List<String> areeList = new List<String>();
        areeList.add('Municipio');
        areeList.add('Aree Tematiche');

        for(Integer i=0; i<numberItems; i++) {
            for(String singleArea: areeList) {
                Favorite__c singleFavorite = new Favorite__c();
                singleFavorite.IsActive__c = true;
                singleFavorite.Type__c = 'Municipio';
                singleFavorite.Name__c = 'Municipio I';
                favoriteList.add(singleFavorite);
            }
        }

        insert favoriteList;
        return favoriteList;
    }

    public static List<ContentDocumentLink> createContentDocumentLinks(List<ContentDocument> contentDocuments, List<Case> cases) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        for(Case c : cases) {
            for(ContentDocument cd : contentDocuments) {
                ContentDocumentLink cdl = new ContentDocumentLink();

                cdl.ContentDocumentId = cd.Id;
                cdl.LinkedEntityId = c.Id;

                contentDocumentLinks.add(cdl);
            }
        }

        insert contentDocumentLinks;
        return contentDocumentLinks;
    }

    public static List<ContentVersion> createContentVersions() {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        ContentVersion cv1 = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );

        ContentVersion cv2 = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );

        ContentVersion cv3 = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
        );

        contentVersions.add(cv1);
        contentVersions.add(cv2);
        contentVersions.add(cv3);

        insert contentVersions;
        return contentVersions;
    }

    public static List<GEDCaseBatch_Setting__c> createGedCaseBatchSettings() {
        List<GEDCaseBatch_Setting__c> settings = new List<GEDCaseBatch_Setting__c>();
        GEDCaseBatch_Setting__c setting = new GEDCaseBatch_Setting__c();
        setting.Batch_Size__c = 200;
        setting.Lowest_Time_Hours__c = 12;
        setting.Upper_Time_Minutes__c = 0;
        setting.Name = 'BatchGEDCase';
        setting.Number_of_Days_Before_to_Consider__c = 10;
        settings.add(setting);

        GEDCaseBatch_Setting__c setting1 = new GEDCaseBatch_Setting__c();
        setting1.Batch_Size__c = 200;
        setting1.Lowest_Time_Hours__c = 12;
        setting1.Upper_Time_Minutes__c = 0;
        setting1.Name = 'BatchGEDCaseBonifica';
        setting1.Number_of_Days_Before_to_Consider__c = 10;
        settings.add(setting1);

        insert settings;
        return settings;
    }

    public static GEDContentVersionBatch_Setting__c createContentVersionBatchSetting() {
        GEDContentVersionBatch_Setting__c setting = new GEDContentVersionBatch_Setting__c();

        setting.Batch_Size__c = 200;
        setting.Name = 'BatchGEDContentVersion';

        insert setting;
        return setting;
    }

    public static StartAttachmentGED__c createStartAttachmentGED() {
        StartAttachmentGED__c setting = new StartAttachmentGED__c();

        setting.Name = '1';
        setting.isActive__c = true;
        setting.StartTime__c = '12:30';
        setting.FinishTime__c = '13:00';

        insert setting;
        return setting;
    }

    public static RequestOpenDataWebService createOpenDataWebService() {
        RequestOpenDataWebService requestOpenDataWebService = new RequestOpenDataWebService();

        requestOpenDataWebService.Esiti = new List<RequestOpenDataWebService.Esiti>();

        RequestOpenDataWebService.Esiti esitiSuccess = new RequestOpenDataWebService.Esiti();
        esitiSuccess.Esito = '1';
        esitiSuccess.Id = '1';
        esitiSuccess.errorCode = '000';
        esitiSuccess.errorMessage = null;

        RequestOpenDataWebService.Esiti esitiFalse = new RequestOpenDataWebService.Esiti();
        esitiFalse.Esito = '0';
        esitiFalse.Id = '1';
        esitiFalse.errorCode = '000';
        esitiFalse.errorMessage = null;

        requestOpenDataWebService.Esiti.add(esitiSuccess);
        requestOpenDataWebService.Esiti.add(esitiFalse);

        return requestOpenDataWebService;
    }

    public static List<ContentVersionToGed__c> createContentVersionToGeds(List<Case> cases ) {
        List<ContentVersionToGed__c> contentVersionToGeds = new List<ContentVersionToGed__c>();

        for(Case c : cases) {
            ContentVersionToGed__c contentVersionToGed = new ContentVersionToGed__c();
            contentVersionToGed.CaseId__c = c.Id;
            contentVersionToGed.numOfAttemptsSendAttachment__c = 0;
            contentVersionToGed.ContentVersionSize__c = 1000;

            contentVersionToGeds.add(contentVersionToGed);
        }

        insert contentVersionToGeds;
        return contentVersionToGeds;
    }

    public static List<Cleaner_Setting__c> createLogCleanerSetting() {
        List<Cleaner_Setting__c> logCleanerSettings = new List<Cleaner_Setting__c>();

        Cleaner_Setting__c logCleanerSetting1 = new Cleaner_Setting__c();
        logCleanerSetting1.Name = 'CalloutLogCleaner';
        logCleanerSetting1.Batch_Size__c = 200;
        logCleanerSetting1.Save_Records_Upto_N_Days__c = 0;
        logCleanerSettings.add(logCleanerSetting1);

        Cleaner_Setting__c logCleanerSetting2 = new Cleaner_Setting__c();
        logCleanerSetting2.Name = 'ErrorLogCleaner';
        logCleanerSetting2.Batch_Size__c = 200;
        logCleanerSetting2.Save_Records_Upto_N_Days__c = 0;
        logCleanerSettings.add(logCleanerSetting2);

        Cleaner_Setting__c logCleanerSetting3 = new Cleaner_Setting__c();
        logCleanerSetting3.Name = 'HistoricalIAMCleaner';
        logCleanerSetting3.Batch_Size__c = 200;
        logCleanerSetting3.Save_Records_Upto_N_Days__c = 0;
        logCleanerSettings.add(logCleanerSetting3);

        insert logCleanerSettings;
        return logCleanerSettings;
    }

    public static List<Callout_logger__c> createCalloutLoggers(Integer numCreateCalloutLogs) {
        List<Callout_logger__c> calloutLoggers = new List<Callout_logger__c>();

        for(Integer i=0; i<=numCreateCalloutLogs; i++) {
            Callout_logger__c logger = new Callout_logger__c();
            logger.ErrorMessage__c = 'some error ' + i;

            calloutLoggers.add(logger);
        }

        insert calloutLoggers;
        return calloutLoggers;
    }

    public static List<Error_Log__c> createErrorLogs(Integer numCreateErrorLogs) {
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();

        for(Integer i=0; i<=numCreateErrorLogs; i++) {
            Error_Log__c logger = new Error_Log__c();
            logger.Error_Message__c = 'some error ' + i;

            errorLogs.add(logger);
        }

        insert errorLogs;
        return errorLogs;
    }

    public static List<Contact> createSigeudContacts(List<Account> personAccounts) {
        List<Contact> contacts = new List<Contact>();

        for(Account acc : personAccounts) {
            Contact con = new Contact();
            con.FirstName = 'TestFirst';
            con.LastName = 'TestLast';
            con.SigeudDate__c = System.today();
            con.Persona_Fisica__c = acc.Id;

            contacts.add(con);
        }

        insert contacts;
        return contacts;
    }

    public static List<Account> createGEDBusinessAccounts(Integer numOfAccounts) {
        List<Account> accounts = new List<Account>();

        for(Integer i=0; i<numOfAccounts; i++) {
            Account acc = new Account();
            acc.Email_Account__c = i+'company@t.it';
            acc.Partita_IVA__c = i+'123456789';
            acc.Name = 'Test Company ' + i;

            accounts.add(acc);
        }

        insert accounts;
        return accounts;
    }

    public static List<Case> createGEDCases(Integer numOfAccounts) {
        List<Account> accounts = createGEDBusinessAccounts(numOfAccounts);
        List<Case> cases = new List<Case>();

        for(Account acc : accounts) {
            Case c = new Case();

            c.Account = acc;
            c.Status = 'New';
            c.Origin = 'CDC';
            c.ToBeSentGED__c = true;
            c.ProtocolCFUser__c = '1234';
            c.COD_SIS__c = 'CODSIS';
            c.COD_DOC__c = 'CODDOC';
            c.DOC_LOGIC__c = 'CODLOGIC';
            c.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Anomaly' LIMIT 1].Id;

            cases.add(c);
        }

        insert cases;
        return cases;
    }

    public static List<Attachment> createAttachmentsFromEmails(List<EmailMessage> emailmessages) {
        List<Attachment> attachments = new List<Attachment>();

        for(EmailMessage e : emailmessages) {
            Attachment a = new Attachment();
            a.Name = 'test';
            a.Body = Blob.valueOf('.');
            a.ParentId = emailmessages[0].Id;

            attachments.add(a);
        }

        insert attachments;
        return attachments;
    }

    public static List<Attachment> createAttachmentsFromEmails(Integer numOfAttachments, String emailMessageId) {
        List<Attachment> attachments = new List<Attachment>();

        for(Integer i=0; i<numOfAttachments; i++) {
            Attachment a = new Attachment();
            a.Name = 'test ' + i + ': ' + emailMessageId;
            a.Body = Blob.valueOf('.');
            a.ParentId = emailMessageId;

            attachments.add(a);
        }

        insert attachments;
        return attachments;
    }

    public static List<Historical_IAM__c> createHistoricalIAMs(Integer numCreateHistoricalIams) {
        List<Historical_IAM__c> historicalIAMs = new List<Historical_IAM__c>();

        for(Integer i=0; i<=numCreateHistoricalIams; i++) {
            Historical_IAM__c iam = new Historical_IAM__c();

            historicalIAMs.add(iam);
        }

        insert historicalIAMs;
        return historicalIAMs;
    }

    public static IAMBatch_Setting__c createIamBatchSetting() {
        IAMBatch_Setting__c iamBatchSetting = new IAMBatch_Setting__c(Name = 'BatchIntegrationToIAM', Batch_Size__c = 200, Lowest_Time_Days__c = 1, Upper_Time_Minutes__c = 1);

        insert iamBatchSetting;
        return iamBatchSetting;

    }

    public static ConsentsBatch_Setting__c createConsentsBatchSetting() {
        ConsentsBatch_Setting__c consentsBatchSetting = new ConsentsBatch_Setting__c();

        consentsBatchSetting.Batch_Size__c = 200;
        consentsBatchSetting.Name = 'BatchBonificaConsensi';
        consentsBatchSetting.Consents_Expiry_Num_Days__c = 0;

        insert consentsBatchSetting;
        return consentsBatchSetting;
    }
}