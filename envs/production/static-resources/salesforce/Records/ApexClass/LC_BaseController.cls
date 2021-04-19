public without sharing class LC_BaseController {
    
    public static Map<String, String> implementationMap = new Map<String, String>{
        'LC_AccountHierarchy' => 'LC_AccountHierarchy'
    };

        //Map param name => param value
        @AuraEnabled
        public static Response execute(String controllerName, Map <String, Object> params){
            try {

                system.debug('params '+ params);
                if (!implementationMap.containsKey(controllerName)){
                    throw new LC_BaseControllerException(' NO IMPLIMENTATION FOR '+controllerName);
                }

                ILCController executer = (ILCController)Type.forName(implementationMap.get(controllerName)).newInstance() ;
                return executer.executeAction(params);

            } catch (Exception e) {
                System.debug('Error on line :'+e.getLineNumber()+' stack trace '+e.getStackTraceString()+ ' message '+e.getMessage());
                return new Response(e);
            }

        }

    public class LC_BaseControllerException extends Exception{}

}