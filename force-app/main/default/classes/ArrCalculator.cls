public with sharing class ArrCalculator {
    public static final String QUOTE_TYPE_NEW_CONTARCT = 'New Contract';
    public static final String QUOTE_TYPE_PRORATED = 'Pro-rated';

    public static Decimal AddedArr(String quoteType, Decimal priorArr, Decimal priorSeats, Decimal expectedSeats, Decimal seatPrice, Decimal exchangeRate) {
        if (String.isBlank(quoteType) || priorArr == null || priorSeats == null || expectedSeats ==  null || seatPrice == null || exchangeRate == null) { return null; }

        Decimal addedArr;

        if (quoteType == QUOTE_TYPE_NEW_CONTARCT) {
            addedArr = expectedSeats * 12 * exchangeRate * seatPrice - priorArr;
        } else if (quoteType == QUOTE_TYPE_PRORATED) {
            addedArr = (expectedSeats - priorSeats) * 12 * exchangeRate * seatPrice;
        } else {
            return null;
        }

        if (addedArr == 0) { return null; }

        return addedArr;
    }
}
