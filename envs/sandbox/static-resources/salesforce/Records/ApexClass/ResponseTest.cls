@isTest
public class ResponseTest {

    @isTest
    static void responseTest() {
        new Response();
        new Response('result');
        new Response(true, 'Success', 'success');
        new Response(new CustomException());
    }
    
    class CustomException extends Exception {}
}