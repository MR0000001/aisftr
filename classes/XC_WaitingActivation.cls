/**
 * Created by dolombardi on 03/08/2021.
 */

public with sharing class XC_WaitingActivation {

    public class Requests {
        @InvocableVariable(label='Records for Input' description='yourDescription' required=true)
        public List<Boolean> inputCollection;
    }

    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public Boolean outputMember;
    }


    @InvocableMethod
    public static List <Results> setTimeOutD(){
        Results response = new Results();
        response.outputMember = false;
        Integer b = 1;
        for(Integer a = 0; a<999999; a++){
            b= b+1;
            if (a == 999998){
                response.outputMember = true;
                break;

            }
        }
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    }



}