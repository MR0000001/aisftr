/*
* @author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
* @date Creation 31/07/2020
* @date Modification dd/mm/yyyy
* @description CSVHeader
*/
public class Giic_CSVHeader {
    
    @AuraEnabled
    public String column_name {get; set;}

    @AuraEnabled
    public String column_type {get; set;}

    public Giic_CSVHeader(String column_name, String column_type) {
        this.column_name = column_name;
        this.column_type = column_type;
    } 

    public Giic_CSVHeader(String column_name) {
        this.column_name = column_name;
        this.column_type = '';
    }
    
    

}