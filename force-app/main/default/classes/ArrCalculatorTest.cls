@isTest
public class ArrCalculatorTest {
    static testMethod void anyArgEmtpyReturnsNull(){
        Test.startTest();
        System.assertEquals(null, ArrCalculator.AddedArr(null, 1, 1, 1, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr('', 1, 1, 1, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr('null', 1, 1, 1, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, null, 1, 1, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 1, null, 1, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 1, 1, null, 1, 1));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 1, 1, 1, null, 1));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 1, 1, 1, 1, null));
        Test.stopTest();
    }

    static testMethod void addedArrZeroReturnsNull(){
        Test.startTest();

        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_PRORATED, 1, 1, 1, 1, 0));
        System.assertEquals(null, ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 12, 1, 1, 1, 1));

        Test.stopTest();
    }

    static testMethod void newContract(){
        Test.startTest();
        System.assertEquals(
            35,
            ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_NEW_CONTARCT, 1, 2, 3, 1, 1)
        );
        Test.stopTest();
    }

    static testMethod void proRatedContract(){
        Test.startTest();
        System.assertEquals(
            12,
            ArrCalculator.AddedArr(ArrCalculator.QUOTE_TYPE_PRORATED, 1, 2, 3, 1, 1)
        );
        Test.stopTest();
    }
}