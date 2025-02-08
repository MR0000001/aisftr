/**
* @author PA NTTDATA - 
* @date Creation 22/06/2019
* @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
* @description Called from Apex XC_NE_AddTechnicalItem_Controlle to load map with id product and related price selected technical cart
*/

public class XC_JSON2Apex {
        /** @description The contract id. */
    public String prodPrice {get;set;} 
        /** @description The contract id. */
    public String id {get;set;} 
        /** @description The contract id. */
    public String quantity {get;set;}
        /** @description The contract id. */
    public String glBookEntryId {get;set;}
    
    /**
    * @author PA NTTDATA - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description Cart Technical Configuration Item
    * @param parser JSONParser
    */
    public XC_JSON2Apex(JSONParser parser) {
        system.debug('@@@ JSON2Apex:' + parser);
         boolean check =false;
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
               
                if (parser.nextToken() == System.JSONToken.VALUE_NULL) {
                    system.debug('@@@@ XC_JSON2Apex - text:');
                }else{    
                   /* if (text == 'prodPrice') {
                        prodPrice = parser.getText();
                    } else if (text == 'Id') {
                        Id = parser.getText();
                     } else if (text == 'Quantity') {
                        quantity = parser.getText();    
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }*/
                    system.debug('@@@@ XC_JSON2Apex - text:' + text + ' - value:' + parser.getText());

                    switch on text {

                       when 'prodPrice' {
                         prodPrice = parser.getText();
                       }
                       when 'id' {
                        id = parser.getText();
                       }
                        when 'Quantity' {
                        quantity = parser.getText();
                       }
                         when 'glBookEntryId' {
                        glBookEntryId = parser.getText();
                       }
                       when else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                       }
                     }   
                   /****************************/
                }
            }
        }
    }
    
     /**
    * @author PA NTTDATA - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description Cart Technical Configuration Item
    * @param json string
    * @return List<XC_JSON2Apex>
    */
    public static List<XC_JSON2Apex> parse(String json) {
        system.debug('@@@@ parse;' + json);
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfJSON2Apex(parser);
    }
    
     /**
    * @author PA NTTDATA - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description Cart Technical Configuration Item
    * @param parser System.JSONParser
    */
    public static void consumeObject(System.JSONParser parser) {
        system.debug('@@@@ consumeObject;' + parser);
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
      /**
    * @author PA NTTDATA - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description Cart Technical Configuration Item
    * @param p System.JSONParser
    * @return List<XC_JSON2Apex> 
    */
    private static List<XC_JSON2Apex> arrayOfJSON2Apex(System.JSONParser p) {
        system.debug('@@@ p.getCurrentToken():' + p.getCurrentToken());
        List<XC_JSON2Apex> res = new List<XC_JSON2Apex>();
        if (p.getCurrentToken() == null){ p.nextToken();}
        
         system.debug('@@@ System.JSONToken.END_ARRAY:' + System.JSONToken.END_ARRAY);
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new XC_JSON2Apex(p));
        }
        return res;
    }
    
}