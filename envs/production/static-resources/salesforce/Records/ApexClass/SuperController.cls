public without sharing class SuperController {

    public static Map<String, String> implementationMap = new Map<String, String>{
        'StoryLogController' => 'StoryLogController'
    };

    @AuraEnabled
    public static Response execute(String controllerName, Map <String, Object> params) {
        try {
            if (!implementationMap.containsKey(controllerName)) {
                throw new SuperControllerException('NO IMPLEMENTATION FOR ' + controllerName);
            }

            ISuperController executor = (ISuperController) Type.forName(implementationMap.get(controllerName)).newInstance();
            return executor.executeAction(params);

        } catch (Exception ex) {
            System.debug('Error on line :' + ex.getLineNumber() + ' stack trace ' + ex.getStackTraceString() + ' message ' + ex.getMessage());
            return new Response(false, ex.getMessage(), null);
        }
    }

    public class SuperControllerException extends Exception {
    }
}