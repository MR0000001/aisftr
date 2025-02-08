/**
 * @author            : Vamsi Sree Nekkanti
 * @created date      : 23-08-2022
 * @description       :
 * @testClasses       : TestGeoromaCallouts,TestGeoromaController
 * @last modified by  : Davide Desideri
 * @last modified on  : 08-06-2023
 **/

public without sharing class GeoromaCallouts {
  public static ResponseGeoromaStreetsList getStreetsListCallout(String streetQuery) {
    DebugService.printLimits('GeoromaCallouts', 'getStreetsListCallout', 'start');
    Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance(
      'Georoma_GetStreetsList'
    );

    CalloutHelper.setStartTime();
    HttpRequest req = null;
    ResponseGeoromaStreetsList responseStreets = null;

    req = createHTTPRequest(streetQuery, commonCalloutSettings, '');

    if (req != null) {
      System.debug('Request is not null');
      try {
        responseStreets = (ResponseGeoromaStreetsList) JSON.deserialize(
          callout(req, commonCalloutSettings),
          ResponseGeoromaStreetsList.class
        );
      } catch (Exception e) {
        ErrorLogEventHandler.standardExceptionLog('GeoromaCallouts', 'getStreetsListCallout', e);
        throw newMessageException(Label.Georoma_Errors_GetStreetsListFailed);
      }
    }

    System.debug('responseStreets ' + responseStreets);
    DebugService.printLimits('GeoromaCallouts', 'getStreetsListCallout', 'end');

    return responseStreets;
  }

  public static ResponseGeoromaStreetDetails getStreetDetailsCallout(String streetName, String streetNumber) {
    DebugService.printLimits('GeoromaCallouts', 'getStreetDetailsCallout', 'start');
    Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance(
      'Georoma_GetStreetDetails'
    );

    CalloutHelper.setStartTime();
    HttpRequest req = null;
    ResponseGeoromaStreetDetails responseGeoromaStreetDetails = null;
    RequestGeoromaStreetDetails requestGeoromaStreetDetails = new RequestGeoromaStreetDetails(
      streetName,
      streetNumber,
      Label.Georoma_Epsg
    );
    String reqJson = JSON.serialize(requestGeoromaStreetDetails);
    req = createHTTPRequest('', commonCalloutSettings, reqJson);

    if (req != null) {
      System.debug('Request is not null');
      try {
        responseGeoromaStreetDetails = (ResponseGeoromaStreetDetails) JSON.deserialize(
          callout(req, commonCalloutSettings),
          ResponseGeoromaStreetDetails.class
        );
      } catch (Exception e) {
        ErrorLogEventHandler.standardExceptionLog('GeoromaCallouts', 'getStreetDetailsCallout', e);
        throw newMessageException(Label.Georoma_Errors_GetStreetDetailsFailed);
      }
    }

    System.debug('responseGeoromaStreetDetails ' + responseGeoromaStreetDetails);
    DebugService.printLimits('GeoromaCallouts', 'getStreetDetailsCallout', 'end');

    return responseGeoromaStreetDetails;
  }

  private static HttpRequest createHTTPRequest(
    String streetQuery,
    Callout_Common_Settings__mdt commonCalloutSettings,
    String reqJson
  ) {
    DebugService.printLimits('GeoromaCallouts', 'createHTTPRequest', 'start');
    HttpRequest req = null;

    try {
      String accessToken = WSO2AuthCallout.WSO2AuthCallout();
      if (String.isNotBlank(accessToken)) {
        req = CalloutHelper.initializeRequest(
          commonCalloutSettings.Endpoint__c + streetQuery,
          commonCalloutSettings.Method__c,
          Integer.valueOf(commonCalloutSettings.Timeout_Value__c),
          commonCalloutSettings.Header_Content_Type__c,
          commonCalloutSettings.Auth_Type__c + ' ' + accessToken,
          commonCalloutSettings.Header_Accept_Type__c,
          reqJson
        );
        DebugService.printRequest('GeoromaCallouts', 'createHTTPRequest', req);
      }
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('GeoromaCallouts', 'createHTTPRequest', e);
      throw newMessageException(Label.Georoma_Errors_RequestFailed);
    }
    DebugService.printLimits('GeoromaCallouts', 'createHTTPRequest', 'end');

    return req;
  }

  private static String callout(HttpRequest req, Callout_Common_Settings__mdt commonCalloutSettings) {
    DebugService.printLimits('GeoromaCallouts', 'callout', 'start');
    Long totalTime = null;
    HttpResponse res = null;
    String responseBody;
    try {
      totalTime = CalloutHelper.getTotalTime();
      System.debug('totalTime ' + totalTime);
      res = new Http().send(req);
      DebugService.printResponse('GeoromaCallouts', 'callout', res);
      CalloutLoggerService.initializeUpdateCalloutLog(
        req,
        res,
        req.getBody(),
        totalTime,
        '',
        commonCalloutSettings.Label,
        commonCalloutSettings.Endpoint__c,
        ''
      );

      if (res.getStatusCode() == 200) {
        System.debug('Entered Response OK');
        responseBody = res.getBody();
      }
    } catch (Exception e) {
      DebugService.printException('GeoromaCallouts', 'callout', e);
      CalloutHelper.handleException(
        res,
        req,
        req.getBody(),
        totalTime,
        commonCalloutSettings.Label,
        commonCalloutSettings.Endpoint__c,
        e
      );
    }
    DebugService.printLimits('GeoromaCallouts', 'callout', 'end');

    return responseBody;
  }

  private static Exception newMessageException(String message) {
    DebugService.printLimits('GeoromaCallouts', 'newMessageException', 'start');
    Exception e;
    Request reqInfo = Request.getCurrent();
    switch on reqInfo.getQuiddity() {
      when VF, AURA {
        e = new AuraHandledException(message);
      }
      when else {
        e = new RequestFailedException(message);
      }
    }
    DebugService.printLimits('GeoromaController', 'newMessageException', 'end');
    return e;
  }

  public class RequestFailedException extends Exception {
  }
}