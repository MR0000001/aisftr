/**
 * @author            : Daniel Perrella
 * @created date      : 10-11-2023
 * @description       : RCC-2001
 * @testClasses       : TestBatchNotifyKnowledgeInactivityUsers
 * @last modified by  : Daniel Perrella
 * @last modified on  : 20-11-2023
 **/
global with sharing class BatchNotifyKnowledgeInactivityUsers implements Database.Batchable<SObject>, Schedulable {
  private static final String BATCH_NAME = 'BatchNotifyKnowledgeInactivityUsers';
  private static final UserNotificationKM__c cSetting = UserNotificationKM__c.getOrgDefaults();
  private static final Batch_Configuration__mdt mSetting = Batch_Configuration__mdt.getInstance(BATCH_NAME);

  global Database.QueryLocator start(Database.BatchableContext bc) {
    Date startDateToSearch = Date.today().addDays(-Integer.valueOf(cSetting.Inactivity_Days__c));
    String query = 'SELECT Id, Email, Name, Profile.Name, SerialNumber__c, LastKnowledgeNotification__c, ( SELECT Id, LastPublishedDate FROM Knowledge__r WHERE RecordType.DeveloperName IN (\'News_Publish\', \'Card_Service_Publish\') AND PublishStatus IN (\'Online\',\'Archived\') AND LastPublishedDate >= :startDateToSearch ORDER BY LastPublishedDate DESC LIMIT 1 ) FROM User';
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'start', 'start');
    if (!cSetting.NoNotifications__c) {
      query += Test.isRunningTest()
        ? ' WHERE Alias = \'NotifKM\''
        : ' WHERE isActive = TRUE AND UserPermissionsKnowledgeUser = TRUE AND Profile.Name IN (\'Utenti DEA\', \'URP\', \'Istruttore\')';
      return Database.getQueryLocator(query);
    }
    return Database.getQueryLocator(query + ' LIMIT 0');
  }

  global void execute(Database.BatchableContext bc, List<User> scope) {
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'execute', 'start');
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    execute(scope);

    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'execute', 'end');
  }

  global void finish(Database.BatchableContext bc) {
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'finish', 'start');
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'finish', 'end');
  }

  global static void execute(SchedulableContext ctx) {
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'schedule', 'start');
    Database.executeBatch(new BatchNotifyKnowledgeInactivityUsers(), Integer.valueOf(mSetting.Batch_Size__c));
    DebugService.printLimits('BatchNotifyKnowledgeInactivityUsers', 'schedule', 'end');
  }

  public void execute(List<User> users) {
    try {
      DebugService.printList('BatchNotifyKnowledgeInactivityUsers', 'execute', 'scope', users, true);
      // Recupero Macrostrutture per notifica - Start
      List<String> serialNumbers = new List<String>();
      Map<String, String> serialNumberWithMacrostruttura = new Map<String, String>();
      for (User u : users) {
        serialNumbers.add(u.SerialNumber__c);
      }
      for (Employee__c emp : [
        SELECT SerialNumber__c, (SELECT Macrostructure__c FROM Ruoli__r LIMIT 1)
        FROM Employee__c
        WHERE SerialNumber__c IN :serialNumbers
      ]) {
        if (!emp.Ruoli__r.isEmpty()) {
          serialNumberWithMacrostruttura.put(emp.SerialNumber__c, emp.Ruoli__r.get(0).Macrostructure__c);
        }
      }
      // Recupero Macrostrutture per notifica - End

      // Verifica su Singolo Utente - Start
      List<User> userToNotify = new List<User>();
      List<User> userToUpdate = new List<User>();
      for (User u : users) {
        if (!u.Knowledge__r.isEmpty() && u.LastKnowledgeNotification__c != null) {
          // Non notificare e pulire il campo perchè hanno pubblicato
          userToUpdate.add(new User(Id = u.Id, LastKnowledgeNotification__c = null));
        } else if (u.Knowledge__r.isEmpty() && u.LastKnowledgeNotification__c == null) {
          // Da Notificare perchè non hanno pubblicato e non hanno mai ricevuto la notifica
          userToNotify.add(u);
          userToUpdate.add(new User(Id = u.Id, LastKnowledgeNotification__c = Date.today()));
        } else if (
          u.Knowledge__r.isEmpty() &&
          Date.today() <= Date.valueOf(u.LastKnowledgeNotification__c).addDays(Integer.valueOf(cSetting.Next_Days__c))
        ) {
          // Da Notificare perchè non hanno ancora pubblicato e non hanno ancora ricevuto le x notifiche
          userToNotify.add(u);
        }
      }
      // Verifica su Singolo Utente - End

      // Creazione Notifiche - Start
      List<ConnectApi.BatchInput> feedItemInputs = new List<ConnectApi.BatchInput>();
      for (User u : userToNotify) {
        System.debug('User Id: ' + u.Id + ' Name: ' + u.Name);
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = u.Id;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        String macrostruttura = serialNumberWithMacrostruttura.containsKey(u.SerialNumber__c)
          ? serialNumberWithMacrostruttura.get(u.SerialNumber__c)
          : '';
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text =
          ' - ' +
          macrostruttura +
          System.Label.BodyKMNotification +
          '#' +
          System.Label.NotificheKM +
          '\n\n';
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = u.Id;
        feedItemInputs.add(new ConnectApi.BatchInput(feedItemInput));
      }
      if (!Test.isRunningTest()) {
        List<ConnectApi.BatchResult> feedBatchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(
          null,
          feedItemInputs
        );
      }
      // Creazione Notifiche - End

      update userToUpdate; //Update Campo LastKnowledgeNotification__c sugli User
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('BatchNotifyKnowledgeInactivityUsers', 'execute', e);
    }
  }
}