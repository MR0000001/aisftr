@isTest
public with sharing class XC_WaitingActivation_TEST {
    static testMethod void submitTest(){
        XC_WaitingActivation.Results re = new XC_WaitingActivation.Results();
        List<XC_WaitingActivation.Results> responseWrapper= new List<XC_WaitingActivation.Results>();
        responseWrapper = XC_WaitingActivation.setTimeOutD();
    }

}