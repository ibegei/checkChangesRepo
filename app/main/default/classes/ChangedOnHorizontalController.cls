public class ChangedOnHorizontalController {
	@AuraEnabled
    public static String getDetails(Id recordId) {
        Integer currentMonth = System.Today().month();
        //Integer currentMonth = 4;
        System.debug('currentMonth---'+currentMonth);
        Map<Integer,String> monthMap = new Map<Integer,String> {
                                                                1 => 'Jan',
                                                                2 => 'Feb',
                                                                3 => 'Mar',
                                                                4 => 'Apr',
                                                                5 => 'May',
                                                                6 => 'Jun',
                                                                7 => 'Jul',
                                                                8 => 'Aug',
                                                                9 => 'Sep',
                                                                10 => 'Oct',
                                                                11 => 'Nov',
                                                                12 => 'Dec'
                                                            };
        //Integer counter=6;
        Map<String,Integer> monthValueMap = new Map<String,Integer>();
        for(Integer counter=6; counter > 0; counter--)
        {
            
            if(currentMonth < 1)
            {
                currentMonth = 12;
                System.debug('currentMonth--'+currentMonth+'--------'+monthMap.get(currentMonth));
            	monthValueMap.put(monthMap.get(currentMonth),0);
            }
            else
            {
                System.debug('currentMonth--'+currentMonth+'--------'+monthMap.get(currentMonth));
            	monthValueMap.put(monthMap.get(currentMonth),0);
            }
            currentMonth--;
        }
        System.debug('monthValueMap---'+monthValueMap);
        DateTime sixMonthsBeforeDateTime = System.now().addMonths(-6);
        for(Flosum__Patch_Manifest__c manif : [Select id, Flosum__File_Name__c, Flosum__Last_Updated_On__c from Flosum__Patch_Manifest__c where Flosum__Patch__c =: recordId AND Flosum__Last_Updated_On__c >: sixMonthsBeforeDateTime])
        {
            if(manif.Flosum__Last_Updated_On__c != null)
            {
                Integer cMonth = manif.Flosum__Last_Updated_On__c.month();
                String monthName = monthMap.get(cMonth);
                Integer tempCount = 0;
                if(monthValueMap.containsKey(monthName))
                {
                    tempCount = monthValueMap.get(monthName);
                    tempCount++;
                	monthValueMap.put(monthName,tempCount);
                }
                
                System.debug('monthName--'+monthName+'--------'+tempCount);
            }
            
        }
        System.debug(monthValueMap);
        String detailString = JSON.serialize(monthValueMap);
   		return detailString;
    }
}