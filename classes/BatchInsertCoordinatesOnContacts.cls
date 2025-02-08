/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : TestBatchInsertCoordinatesOnContacts
 * @last modified by  : Daniel Perrella
 * @last modified on  : 27-06-2023
 **/
global without sharing class BatchInsertCoordinatesOnContacts implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
  private static final String BATCH_NAME = 'BatchInsertCoordinatesOnContacts';

  global Database.QueryLocator start(Database.BatchableContext bc) {
    Batch_Configuration__mdt bcc = [
      SELECT Query__c, Query_Where__c, Query_Limit__c, Lowest_Time_Day__c
      FROM Batch_Configuration__mdt
      WHERE DeveloperName = :BATCH_NAME
    ];
    // string query = 'SELECT Id,IsPersonAccount,OtherLatitude,OtherLongitude FROM Contact WHERE IsPersonAccount = true AND OtherLatitude = null AND OtherLongitude = null LIMIT 50000';
    return Database.getQueryLocator(
      String.format(
        '{0} {1} AND {2} LIMIT {3}',
        new List<Object>{
          bcc.Query__c,
          bcc.Query_Where__c,
          String.isEmpty(bcc.Lowest_Time_Day__c)
            ? 'LastGeoromaIntegrationCoordinates__c = null'
            : '(LastGeoromaIntegrationCoordinates__c = null OR LastGeoromaIntegrationCoordinates__c >= ' +
              Datetime.now().addDays(-Integer.valueOf(bcc.Lowest_Time_Day__c)).format('yyyy-MM-dd') +
              ')',
          Integer.valueOf(bcc.Query_Limit__c)
        }
      )
    );
  }

  global void execute(Database.BatchableContext bc, List<Contact> scope) {
    for (Contact c : scope) {
      try {
        BonificaIndirizzi.Residenza address = BonificaIndirizzi.bonificaIndirizzo(c.OtherStreet);
        System.debug(
          LoggingLevel.INFO,
          c.Id + ' have complete address: ' + address.indirizzo + ' - ' + address.civico + ' - ' + address.lettera
        );
        GeoromaController.StreetWrapper dati = GeoromaController.getStreetDetails(address.indirizzo, address.civico);
        System.debug(LoggingLevel.INFO, c.Id + ' georoma response: ' + dati);
        String civicWithLetter = address.civico + address.lettera;
        System.debug(LoggingLevel.INFO, c.Id + ' civicWithLetter: ' + civicWithLetter);
        if (String.isBlank(dati.streetName)) {
          System.debug(LoggingLevel.ERROR, c.Id + ' GeoRoma response is null');
        } else if (!dati.streetDetails.containsKey(civicWithLetter)) {
          System.debug(LoggingLevel.ERROR, c.Id + ' haven\'t found civic from GeoRoma for that street');
        } else {
          c.OtherLatitude = dati.streetDetails.get(civicWithLetter).latitude;
          c.OtherLongitude = dati.streetDetails.get(civicWithLetter).longitude;
        }
      } catch (BonificaIndirizzi.EmptyAddressException emptyAddressExc) {
        System.debug(LoggingLevel.ERROR, c.Id + ' have otherAddress field empty');
      } catch (BonificaIndirizzi.IncompleteAddressException incompleteAddrExc) {
        System.debug(LoggingLevel.ERROR, c.Id + ' haven\'t a complete address');
      } catch (GeoromaCallouts.RequestFailedException reqFailExc) {
        System.debug(LoggingLevel.ERROR, c.Id + ' request failed');
      } catch (GeoromaController.StreetNotFoundException streetNotFoundExc) {
        System.debug(LoggingLevel.ERROR, c.Id + ' returned street not found');
      } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, c.Id + ' generic exception ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, e.getStackTraceString());
      } finally {
        c.LastGeoromaIntegrationCoordinates__c = Date.today();
      }
    }
    update scope;
  }
  global void finish(Database.BatchableContext bc) {
  }

  global static void execute(SchedulableContext ctx) {
    DebugService.printLimits('BatchInsertCoordinatesOnContacts', 'schedule', 'start');
    try {
      Database.executeBatch(
        new BatchInsertCoordinatesOnContacts(),
        Integer.valueOf(
          [
            SELECT Batch_Size__c
            FROM Batch_Configuration__mdt
            WHERE DeveloperName = :BATCH_NAME
          ]
          .Batch_Size__c
        )
      );
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('BatchInsertCoordinatesOnContacts', 'schedule', e);
    }
    DebugService.printLimits('BatchInsertCoordinatesOnContacts', 'schedule', 'end');
  }

  public class IncompleteAddressException extends Exception {
  }
}